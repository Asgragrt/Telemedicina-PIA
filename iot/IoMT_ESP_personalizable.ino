#if defined(ESP32)
#include <WiFi.h>
#include <WiFiMulti.h>
#include <WebServer.h>
#include <HTTPClient.h>
WiFiMulti WiFiMulti;
WebServer server(80);  
WiFiClient wifiClient;
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPClient.h>
ESP8266WiFiMulti    WiFiMulti;
ESP8266WebServer server(80);  
WiFiClient wifiClient;
#endif

#include <WebSocketsServer.h>    
#include <Ticker.h>
WebSocketsServer webSocket = WebSocketsServer(81);  
Ticker blinker;

#include "conexiones.h"
#include "respuestasHTML.h"
#define LED 2  

// Store data in the EEPROM
#include <Preferences.h>
Preferences preferences;

int interval = 1000; 
unsigned long previousMillis = 0; 
unsigned long ultimo_post = 0;
unsigned long current_millis = 0;
const uint32_t TiempoEsperaWifi = 5000;
String texto = "temperatura=";
float oxigeno;
float vref = 3.3;
float resolucion = vref/1023;

String nombre = "";
String ingreso = ""; 
String tiempo = ""; 

void setup() {
  Serial.begin(115200);          
  //  Establecer conexion WiFi                      
  WiFiMulti.addAP(ssid_1,password_1);
  WiFiMulti.addAP(ssid_2,password_2);                 
  Serial.println("Establishing connection to WiFi ...");     
  while (WiFiMulti.run(TiempoEsperaWifi) != WL_CONNECTED) {
    delay(100);
    Serial.print(".");
  }
  Serial.print("Connected to network with IP address: ");
  Serial.println(WiFi.localIP());                    

  //  Inicializacion del WebSocket
  webSocket.begin();                                 
  webSocket.onEvent(webSocketEvent);    

  //Memory management
  preferences.begin("Configuration", false);

  //  Inicializacion del Servidor
  server.on("/", []() {                              
    server.send(200, "text/html", index_html);          
  });

  server.on("/configuracion", []() {                              
    String personalizacion_html = "";

    //Get values from memory
    nombre  = preferences.getString("nombre", String(""));
    ingreso = preferences.getString("ingreso", String(""));
    tiempo  = preferences.getString("tiempo", String(""));

    personalizacion_html  = String(personalization_1)+nombre;
    personalizacion_html += String(personalization_2)+ingreso;
    personalizacion_html += String(personalization_3)+tiempo;
    personalizacion_html += String(personalization_4)+interval+String(personalization_5);

    server.send(200, "text/html", personalizacion_html);          
  });

  server.on("/personalizar", []() {
    String message = "";
    if (server.arg("Nombre")== ""){     
      message += "\nNo se recibio un nuevo nombre";
    }else{
      message += "\nNombre recibido = ";
      nombre   = server.arg("Nombre");
      message += server.arg("Nombre");

      //Store values in non-volatile memory
      preferences.putString("nombre", nombre);
    }

    if (server.arg("Ingreso")== ""){     
      message += "\nNo se recibio fecha de ingreso";
    }else{
      message += "\nIngreso en = ";
      ingreso =  server.arg("Ingreso");
      message += server.arg("Ingreso");

      //Store values in non-volatile memory
      preferences.putString("ingreso", ingreso);
    }

    if (server.arg("Tiempo")== ""){     
      message += "\nNo se recibio tiempo de uso";
    }else{
      message += "\nTiempo de uso = ";
      tiempo   = server.arg("Tiempo");
      message += server.arg("Tiempo");

      //Store values in non-volatile memory
      preferences.putString("tiempo", tiempo);
    }

    if (server.arg("Tasa")== ""){     
      message += "\nNo se recibio tasa de muestreo";
    }else{
      message += "\nTasa de muestreo = ";
      interval = server.arg("Tasa").toInt();
      message += server.arg("Tasa");
    }

    // Serial.print("Nombre en dispositivo: ");
    Serial.println(message);
    
    server.send(200, "text/plain", message);          
  });

  
  server.begin();                                    

  //  Inicializacion de reloj interno para Fs invariable
  blinker.attach(0.75, leerSensor); 
}

void loop() {
  if (WiFi.status() == WL_CONNECTED){
    //  Recepcion de peticiones de dispositivos conectados
    server.handleClient();                              
    webSocket.loop();                                   

    //  Uso de funcion millis para actualizar valor del WebSocket
    unsigned long now = millis();                       
    if ((unsigned long)(now - previousMillis) >= interval) { 
      String str = String(oxigeno);                 
      int str_len = str.length() + 1;                   
      char char_array[str_len];
      str.toCharArray(char_array, str_len);             
      webSocket.broadcastTXT(char_array);               
      previousMillis = now;                             
    }

    /*
    //  Envio de datos leidos al servidor (Python) cada 30s
    current_millis = millis();
    if (current_millis - ultimo_post>30000){
      ultimo_post = current_millis;
      leerSensor();
      //  Establecer connecion al URL correcto (actualizar con valor generado por Flask)
      HTTPClient http; 
      http.begin(wifiClient,"http://192.168.81.136:8090/temperatura");
      http.addHeader("Content-Type", "application/x-www-form-urlencoded");
      int httpCod = http.POST(texto);
      if(httpCod == 200){
          String respuesta = http.getString();
          Serial.println("El servidor respondió: ");
          Serial.println(respuesta);
      } else {
          Serial.println("El servidor respondió: ");
          Serial.println(httpCod);
      }
      http.end(); 
    }
    */
  }
}

void leerSensor(){
  //  Lectura de sensor atado a la funcion blinker definida en el setup.
  digitalWrite(LED, !(digitalRead(LED)));  
  oxigeno = random(85, 100);
  Serial.print("Oxigenacion medida: ");
  Serial.println(oxigeno);
  //texto = "oxigeno=";
  //texto +=temperatura;  //  Conversion a texto para enviar al servidor (Python)
}

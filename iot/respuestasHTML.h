//  Respuesta HTML almacenada en memoria
//  El contenido puede ser modificado para su pagina de preferencia
char index_html[] PROGMEM = R"=====(
<meta charset="UTF-8">
<html>
<head><title>Ox&iacute;metro IoT</title></head>
<body style='background-color: #EEEEEE;'>
<span style='color: #003366;'>
<h1>Lectura actual de oxígeno (PO2).</h1>
<p>Ultima actual: <span id='rand'>-</span></p>
<p><button type='button' id='BTN_SEND_BACK'>
Send info to ESP32</button>
</p>
<p>
<a href='/configuracion'>
<button type='button'>
Ir a Configuración
</button>
</a>
</p>
</span></body>
<script> 
var Socket; 
document.getElementById('BTN_SEND_BACK').addEventListener('click', button_send_back); 
function init() { 
  Socket = new WebSocket('ws://' + window.location.hostname + ':81/'); 
  Socket.onmessage = function(event) { processCommand(event); }; } 
function button_send_back() { Socket.send('Sending back some random stuff'); } 
function processCommand(event) { 
  document.getElementById('rand').innerHTML = event.data; 
  //console.log(event.data); 
  } 
window.onload = function(event) { init(); }
</script></html>
)=====";

const char personalization_html[5000] PROGMEM={};

const char personalization_1[] PROGMEM = R"=====(
<html>
    <head>
        <title>Configuracion</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-KK94CHFLLe+nY2dmCWGMq91rCGa5gtU4mk92HdvYe+M/SXH301p5ILy+dN9+nJOZ" crossorigin="anonymous">
    </head>

    <body style='background-color: #EEEEEE;'>
        <span style='color: #003366;'>
            <h1>Configuracion del dispositivo.</h1>
        </span>

        <div style="width: 500px;">
            <table class="table">
                <tr>
                    <th>Paciente ID</th>
                    <th>Registro</th>
                    <th>Tiempo</th>
                    <th>Refresh rate</th>
                </tr>
                <tr>
                    <td>
)=====";

const char personalization_2[] PROGMEM = R"=====(
</td>
                <td>
)=====";

const char personalization_3[] PROGMEM = R"=====(
</td>
                <td>
)=====";

const char personalization_4[] PROGMEM = R"=====(
</td>
                <td>
)=====";

const char personalization_5[] PROGMEM = R"=====(
                ms</td>
                </tr>

            </table>
        </div>

        
    </body>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ENjdO4Dr2bkBIFxQpeoTz1HIcje39Wm4jDKdf19U8gI4ddQ3GYNS7NTKfAdVQSZe" crossorigin="anonymous"></script>
</html>
)=====";

void webSocketEvent(byte num, WStype_t type, uint8_t * payload, size_t length) { 
  //  Funcion minima para manejar conexion bidireccional del WebSocket
  switch (type) {                                     
    case WStype_DISCONNECTED:                         
      Serial.println("Client " + String(num) + " disconnected");
      break;
    case WStype_CONNECTED:                            
      Serial.println("Client " + String(num) + " connected");
      break;
    case WStype_TEXT:                                 
      for (int i=0; i<length; i++) {                  
        Serial.print((char)payload[i]);
      }
      Serial.println("");
      break;
  }
}

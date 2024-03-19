import logging
from flask import Flask, render_template, request, redirect, url_for, flash
import os 
import requests
import json
import datetime
from flask_sqlalchemy  import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from flask_bcrypt import Bcrypt

app =  Flask(__name__)
app.config['SECRET_KEY'] = 'manuel.franciscovcn@uanl.edu.mx@FacMed'

gunicorn_error_logger = logging.getLogger('gunicorn.error')
app.logger.handlers.extend(gunicorn_error_logger.handlers)
app.logger.setLevel(logging.DEBUG)

db_user  =  "postgres" # es "postgres" por default
db_pswdr =  "admin" # es el password creado durante la instalacion
db_host  =  "localhost:5432/" 
db_name  =  "telemedicina_pia" # es "postgres" por default

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://'+db_user+':'+db_pswdr+'@'+db_host+db_name

db = SQLAlchemy(app)

login_manager = LoginManager()
login_manager.login_view = 'login'
login_manager.session_protection = 'strong'
login_manager.login_message_category = 'info'
login_manager.init_app(app)

bcrypt = Bcrypt()
bcrypt.init_app(app)

class accounts(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50))
    password = db.Column(db.String(50))
    email = db.Column(db.String(255))
    created_on = db.Column(db.DateTime)
    full_name = db.Column(db.String(150))
    verif_status = db.Column(db.String(50))
    role_id = db.Column(db.Integer)

class consultas(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer)
    created_on = db.Column(db.DateTime)
    motivo = db.Column(db.String(150))
    diagnostico = db.Column(db.String(150))
    prescripcion = db.Column(db.String(150))
    incapacidad = db.Column(db.String(50))
    dispositivo = db.Column(db.Integer)

class dispositivos(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    device_number = db.Column(db.Integer)
    assigned_to = db.Column(db.Integer)
    assigned_by = db.Column(db.Integer)
    assigned_date = db.Column(db.DateTime)
    assigned_period = db.Column(db.String(20))
    tipo_registro = db.Column(db.String(20))
    remote_ip = db.Column(db.String(20))
    device_type = db.Column(db.String(255))

def processGArequest(uname,upwrd):
    quser = accounts.query.filter_by(username=uname).first()
    if not quser or not bcrypt.check_password_hash(quser.password, upwrd):
        flash('Usuario o contraseña inválidos')
        return redirect('/login')
    
    print("User validated through DB, right password used")
    login_user(quser)
    response = redirect('/dashboard')
    response.set_cookie('telemed_app', str(quser.id))
    return response
    

@app.route("/")
def home():
    return render_template("001_index.html")
    
@app.route('/login', methods = ['GET','POST'])
def login():
    return render_template("002_access.html")

@app.route('/gaccess', methods = ['GET','POST'])
def gaccess(): # Get access
    uname = request.form['uname']
    upwrd = request.form['upwrd']
    print("Trying to login \n\t User: {} \n\t Password: {}".format(uname,upwrd))
    return processGArequest(uname,upwrd)

@app.route('/dashboard')
@login_required
def dashboard():
    user_id = current_user.get_id()
    qaccount = accounts.query.filter_by(id=user_id).first()
    rol_id = qaccount.role_id

    
    if rol_id == 0:    # Administrador
        usuarios = {}
        return render_template('003_board_admin.html',uname=user_id,usuarios=usuarios)
    elif rol_id == 1:    # Paciente
        estudios = consultas.query.filter_by(user_id=int(user_id))
        return render_template('004_board_patient.html',uname=qaccount.full_name,consultas=estudios,rol_id=rol_id)
    elif rol_id == 2:    # Enfermero
        pacientes = accounts.query.filter_by(role_id=1)
        # print("Pacientes found: ",pacientes)
        return render_template('005_board_nurse.html',uname=qaccount.full_name,pacientes=pacientes)
    elif rol_id == 3:    # Medico
        pacientes = accounts.query.filter_by(role_id=1)
        return render_template('006_board_doctor.html',uname=qaccount.full_name,casos=pacientes)
    elif rol_id == 4:    # Medico especialista
        pacientes = accounts.query.filter_by(role_id=1)
        return render_template('006_board_doctor.html',uname=qaccount.full_name,casos=pacientes)
#     elif str(ur_projects.id) == '5':    # Investigador
#         return render_template('boards/manager-board.html',uname=qaccount.full_name,pdata=ur_projects)

def auth(*roles):
    role_id = accounts.query.filter_by(id=current_user.get_id()).first().role_id
    if role_id not in roles:
        flash('Usuario sin permisos')
        return True
    return False

@app.route('/expediente/<user_id>')
@login_required
def expediente(user_id):

    if auth(0, 3, 4):
        return redirect('/dashboard')

    historial = consultas.query.filter_by(user_id=int(user_id))
    paciente = accounts.query.filter_by(id=int(user_id)).first()
    #req_id = request.cookies.get('telemed_app')
    #print("\tLooking for req_id user :",req_id)
    return render_template('007_board_expediente.html',
                           uname=paciente.full_name,
                           patId=user_id,
                           consultas=historial)

@app.route('/agregar/<user_id>')
@login_required
def agregar(user_id):

    if auth(0, 3, 4):
        return redirect('/dashboard')
    
    historial = consultas.query.filter_by(user_id=int(user_id))
    paciente = accounts.query.filter_by(id=int(user_id)).first()
    info_dispositivos = dispositivos.query.all()
    #req_id = request.cookies.get('telemed_app')
    #print("\tLooking for req_id user :",req_id)
    
    return render_template('008_board_nuevoRecord.html',
                           uname=paciente.full_name,
                           patId=user_id,
                           consultas=historial,
                           dispositivos=info_dispositivos)

@app.route('/salvarregistro/<user_id>', methods = ['POST'])
@login_required
def salvarregistro(user_id):
    #Salvar el registro
    try:
        dispositivo_device_number = int(request.form['asignarDispositivo'])
    except:
        dispositivo_device_number = None

    current_time = str(datetime.datetime.now()).split(".")[0] # "date_time",
    db.session.add(consultas(
        user_id = user_id,
        created_on = current_time,
        motivo = request.form['nuevoMotivo'],
        diagnostico = request.form['nuevoRegistro'],
        prescripcion = request.form['nuevaPrescripcion'],
        incapacidad = request.form['nuevaIncapacidad'],
        dispositivo = dispositivo_device_number,
    ))

    #Actualizar el dispositivo
    dispositivo = dispositivos.query.filter_by(device_number=dispositivo_device_number).first()
    dispositivo.assigned_to = user_id
    dispositivo.assigned_by = current_user.get_id()
    dispositivo.assigned_date = current_time
    if period := request.form['periodoAsignado']:
        dispositivo.assigned_period = period
    #Commit changes    
    db.session.commit()

    paciente = accounts.query.filter_by(id=user_id).first()

    #Send to device
    try:
        requests.get(
        f'http://{dispositivo.remote_ip}/personalizar',
        params={
            'Nombre': paciente.full_name,
            'Ingreso': current_time.split()[0],
            'Tiempo': period
            }
        )
    except:
        flash('No se pudo enviar al dispositivo')
    
    return redirect(url_for("expediente",user_id=user_id))

@app.route('/dispositivo/<device_id>')
@login_required
def dispositivo(device_id):
    if auth(0, 3, 4):
        return redirect('/dashboard')
    
    configuracion = dispositivos.query.filter_by(device_number=int(device_id)).first()
    paciente = accounts.query.filter_by(id=int(configuracion.assigned_to)).first()
    #req_id = request.cookies.get('telemed_app')
    consulta = consultas.query.filter_by(dispositivo=configuracion.device_number).order_by(consultas.id.desc()).first()
    return render_template('009_board_dispositivo.html',
                                devType=configuracion.device_type,
                                devID=configuracion.device_number,
                                uname=paciente.full_name,
                                consulta=consulta,
                                assigned_period=configuracion.assigned_period,
                                assigned_date=configuracion.assigned_date)

@app.route('/visualizar/<device_id>')
@login_required
def visualizar(device_id):
    if auth(0, 2, 3, 4):
        return redirect('/dashboard')
    
    configuracion = dispositivos.query.filter_by(device_number=int(device_id)).first()
    #paciente = accounts.query.filter_by(id=int(configuracion.assigned_to)).first()
    #req_id = request.cookies.get('telemed_app')
    return redirect("http://"+configuracion.remote_ip)

@app.route('/modelo_demencia')
@login_required
def modelo_demencia():
    if auth(0, 3, 4):
        return redirect('/dashboard')
    
    model_url = url_for('static', filename='model/model.json')
    weights_url = url_for('static', filename='model/group1-shard1of1.bin')
    return render_template('011_modelo_demencia.html',
                           model_url=model_url,
                           weights_url=weights_url)

@app.route('/listado_dispositivos')
@login_required
def listado_dispositivos():
    if auth(0, 3, 4):
        return redirect('/dashboard')
    
    cuentas = accounts.query.order_by(accounts.id.asc()).all()
    info_dispositivos = dispositivos.query.all()
    return render_template('010_listado_dispositivos.html',
                           info_dispositivos=info_dispositivos,
                           cuentas=cuentas)

@app.route('/cambiar_iot', methods = ['POST'])
@login_required
def cambiar_iot():
    if auth(0, 3, 4):
        return redirect('/dashboard')

    dispositivo = dispositivos.query.filter_by(device_number=int(request.form['asignarDispositivo'])).first()
    parameters=dict()
    if frecuencia := request.form['frecuencia']:
        parameters['Tasa'] = frecuencia

    else:
        paciente = accounts.query.filter_by(id=int(request.form['selectPacientes'])).first()
        current_time = str(datetime.datetime.now()).split(".")[0]
        parameters.update(
            {
            'Nombre': paciente.full_name,
            'Ingreso': current_time.split()[0],
            'Tiempo': request.form['periodo']
            }
        )

        #Actualizar el dispositivo
        dispositivo.assigned_to = paciente.id
        dispositivo.assigned_by = current_user.get_id()
        dispositivo.assigned_date = current_time
        dispositivo.assigned_period = request.form['periodo']
        #Commit changes    
        db.session.commit()

    
    #Send to device
    try:
        requests.get(
            f'http://{dispositivo.remote_ip}/personalizar',
            params=parameters
            )
    except:
        flash('No se pudo enviar al dispositivo')
    

    return redirect('/listado_dispositivos')

@login_manager.user_loader
def load_user(user_id):
    return accounts.query.get(int(user_id))

@app.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect('/')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=82, debug=True)
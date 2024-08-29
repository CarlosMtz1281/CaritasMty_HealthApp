from flask import Flask, jsonify
from users import users_bp
from eventos import eventos_bp
from mediciones import mediciones_bp
from tienda import tienda_bp
import mssql_functions as MSSql
import sys

app = Flask(__name__)

vm_params = {}
vm_params['DB_HOST'] = '100.80.80.7'
vm_params['DB_NAME'] = 'alumno02'
vm_params['DB_USER'] = 'SA'
vm_params['DB_PASSWORD'] = 'Shakira123.'

local_params = {}
local_params['DB_HOST'] = "localhost:1433"
local_params['DB_NAME'] = "master"
local_params['DB_USER'] = "sa"
local_params['DB_PASSWORD'] = "5abr1t0n3s_GOAT"

try:
    MSSql.cnx = MSSql.mssql_connect(local_params)
except Exception as e:
    print("Cannot connect to mssql server!: {}".format(e))
    sys.exit()

app.register_blueprint(users_bp, url_prefix='/users')
app.register_blueprint(eventos_bp, url_prefix='/eventos')
app.register_blueprint(mediciones_bp, url_prefix='/mediciones')
app.register_blueprint(tienda_bp, url_prefix='/tienda')

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.route("/bdtest")
def runquery():
    try:
        cursor = MSSql.cnx.cursor()
        cursor.execute("SELECT * FROM USUARIOS")
        rows = cursor.fetchall()
        result = "<br>".join([str(row) for row in rows])
        return f"<p>Query Result:</p><p>{result}</p>"
    except Exception as e:
        return f"<p>Error running query: {str(e)}</p>"

if __name__ == "__main__":
    app.run(host='localhost', port=8000)

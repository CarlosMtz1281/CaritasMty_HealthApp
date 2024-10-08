from flask import Flask, jsonify
from flasgger import Swagger
from users import users_bp
from eventos import eventos_bp
from mediciones import mediciones_bp
from tienda import tienda_bp
from retos import retos_bp
from database import cnx
from session_manager import validate_key, create_session, delete_session, session_storage

# Remove 'Server' from header
from gunicorn.http import wsgi
class Response(wsgi.Response):
    def default_headers(self, *args, **kwargs):
        headers = super(Response, self).default_headers(*args, **kwargs)
        return [h for h in headers if not h.startswith('Server:')]
wsgi.Response = Response


app = Flask(__name__)

app.register_blueprint(users_bp, url_prefix='/users')
app.register_blueprint(eventos_bp, url_prefix='/eventos')
app.register_blueprint(mediciones_bp, url_prefix='/mediciones')
app.register_blueprint(tienda_bp, url_prefix='/tienda')
app.register_blueprint(retos_bp, url_prefix='/retos')

# Documentación en Swagger
swagger = Swagger(app, template={
    "info":{
        "title": "Documentación Equipo 4",
        "description": "Documentación de endpoints LeSabritones",
        "version": "1.0.0"
    }
 })


@app.route("/")
def get_tables():
    try:
        cursor = cnx.cursor()
        # Query to get all table names in the current database
        cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")
        rows = cursor.fetchall()

        # Extract table names from the result
        tables = [row[0] for row in rows]

        # Return the list of table names as JSON
        return jsonify({"tables": tables})
    except Exception as e:
        return jsonify({"error": str(e)})


@app.route("/bdtest")
def runquery():
    try:
        cursor = cnx.cursor()
        cursor.execute("SELECT * FROM USUARIOS")
        rows = cursor.fetchall()
        result = "<br>".join([str(row) for row in rows])
        return f"<p>Query Result:</p><p>{result}</p>"
    except Exception as e:
        return f"<p>Error running query: {str(e)}</p>"

@app.route("/getSessions")
def get_sessions():
    return jsonify(session_storage)

API_CERT = '/home/user01/mnt/api_https/SSL/sabritones.tc2007b.tec.mx.cer'
API_KEY = '/home/user01/mnt/api_https/SSL/sabritones.tc2007b.tec.mx.key'

if __name__ == '__main__':
    import ssl
    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context.load_cert_chain(API_CERT, API_KEY)
    app.run(host='0.0.0.0', port=10206, ssl_context=context, debug=True)

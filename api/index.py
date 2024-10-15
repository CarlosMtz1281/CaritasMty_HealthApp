from flask import Flask, jsonify, request
from flasgger import Swagger
from users import users_bp
from eventos import eventos_bp
from mediciones import mediciones_bp
from tienda import tienda_bp
from retos import retos_bp
from database import cnx
from session_manager import validate_key, create_session, delete_session, session_storage
import secure
from logger import my_logger  # Import the logger from the logger module

# Remove 'Server' from header
from gunicorn.http import wsgi

class Response(wsgi.Response):
    def default_headers(self, *args, **kwargs):
        headers = super(Response, self).default_headers(*args, **kwargs)
        return [h for h in headers if not h.startswith('Server:')]
wsgi.Response = Response

app = Flask(__name__)

@app.after_request
def add_header(r):
    secure_headers = secure.Secure()
    secure_headers.framework.flask(r)
    r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    r.headers["Content-Security-Policy"] = "default-src 'none'"
    r.headers["Shakira"] = "rocks!"
    return r

app.register_blueprint(users_bp, url_prefix='/users')
app.register_blueprint(eventos_bp, url_prefix='/eventos')
app.register_blueprint(mediciones_bp, url_prefix='/mediciones')
app.register_blueprint(tienda_bp, url_prefix='/tienda')
app.register_blueprint(retos_bp, url_prefix='/retos')

# Swagger documentation
swagger = Swagger(app, template={
    "info": {
        "title": "Documentación Equipo 4",
        "description": "Documentación de endpoints LeSabritones",
        "version": "1.0.0"
    }
})

@app.route("/")
def get_tables():
    my_logger.info("({}) Se hizo una petición".format(request.remote_addr))
    
    try:
        cursor = cnx.cursor()
        cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")
        rows = cursor.fetchall()
        tables = [row[0] for row in rows]
        return jsonify({"tables": tables})
    except Exception as e:
        my_logger.error("Error fetching tables: {}".format(e))
        return jsonify({"error": str(e)})

@app.route("/bdtest")
def runquery():
    my_logger.info("({}) Se hizo una petición".format(request.remote_addr))
    
    try:
        cursor = cnx.cursor()
        cursor.execute("SELECT * FROM USUARIOS")
        rows = cursor.fetchall()
        result = "<br>".join([str(row) for row in rows])
        return f"<p>Query Result:</p><p>{result}</p>"
    except Exception as e:
        my_logger.error("Error running query: {}".format(e))
        return f"<p>Error running query: {str(e)}</p>"

@app.route("/getSessions")
def get_sessions():
    my_logger.info("({}) Requested sessions".format(request.remote_addr))
    return jsonify(session_storage)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000)
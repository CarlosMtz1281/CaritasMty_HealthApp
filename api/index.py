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

# Remove 'Server' from header
from gunicorn.http import wsgi

try:
    import logging
    import logging.handlers
    # Logging (remember the 5Ws: “What”, “When”, “Who”, “Where”, “Why”)
    LOG_PATH = '/var/log/api_http'
    LOGFILE = LOG_PATH  + '/api_http.log'
    logformat = '%(asctime)s.%(msecs)03d %(levelname)s: %(message)s'
    formatter = logging.Formatter(logformat, datefmt='%d-%b-%y %H:%M:%S')
    loggingRotativo = False
    DEV = True
    if loggingRotativo:
        # Logging rotativo
        LOG_HISTORY_DAYS = 3
        handler = logging.handlers.TimedRotatingFileHandler(
                LOGFILE,
                when='midnight',
                backupCount=LOG_HISTORY_DAYS)
    else:
        handler = logging.FileHandler(filename=LOGFILE)
    handler.setFormatter(formatter)
    my_logger = logging.getLogger("api_http")
    my_logger.addHandler(handler)
    if DEV:
        my_logger.setLevel(logging.DEBUG)
    else:
        my_logger.setLevel(logging.INFO)
except:
    pass

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
    #r.headers['X-Frame-Options'] = 'SAMEORIGIN' # ya lo llena 'secure'
    r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    r.headers["Content-Security-Policy"] = "default-src 'none'"
    r.headers["Shakira"] = "rocks!"
    #r.headers["Expires"] = "0"
    return r

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

    my_logger.info("({}) Se hizo una petición".format(request.remote_addr))
    my_logger.debug("({}) Se hizo una petición".format(request.remote_addr))

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

    my_logger.info("({}) Se hizo una petición".format(request.remote_addr))
    my_logger.debug("({}) Se hizo una petición".format(request.remote_addr))
    
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

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000)

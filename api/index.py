from flask import Flask, jsonify
from users import users_bp
from eventos import eventos_bp
from mediciones import mediciones_bp
from tienda import tienda_bp
import mssql_functions as MSSql
from database import cnx
from session_manager import validate_key, create_session, delete_session, session_storage

app = Flask(__name__)

app.register_blueprint(users_bp, url_prefix='/users')
app.register_blueprint(eventos_bp, url_prefix='/eventos')
app.register_blueprint(mediciones_bp, url_prefix='/mediciones')
app.register_blueprint(tienda_bp, url_prefix='/tienda')

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

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000)

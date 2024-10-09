from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import create_session, validate_key, delete_session
import hashlib
import logging

from logger import my_logger  


# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

users_bp = Blueprint('users', __name__)

@users_bp.route('/login', methods=['POST'])
def login():
    logging.info("Login attempt started")
    data = request.json
    correo = data.get('correo')
    password = data.get('password')

    if not correo or not password:
        logging.warning("Missing email or password in request")
        return jsonify({"error": "El correo y la contraseña son requeridos"}), 400

    query = """
    SELECT U.ID_USUARIO AS user_id FROM USUARIOS U WHERE U.CORREO = %s AND U.PASS = %s
    """

    try:
        hash_password = hashlib.sha256(password.encode()).digest()
        cursor = cnx.cursor()
        cursor.execute(query, (correo, hash_password))
        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()

        if not results:
            logging.warning(f"Invalid credentials for user: {correo}")
            return jsonify({"error": "Credenciales inválidas"}), 400

        user_id = results[0]['user_id']
        logging.info(f"User {user_id} logged in successfully")
    except Exception as e:
        logging.error(f"Error during login: {e}")
        return jsonify({"error": str(e)}), 500

    session_key = create_session(user_id)
    logging.info(f"Session created for user {user_id} with key {session_key}")

    return jsonify({"user_id": user_id, "key": session_key}), 200

@users_bp.route('/signOut', methods=['POST'])
def sign_out():
    logging.info("Sign out attempt started")
    session_key = request.headers.get('key')
    user_id = request.headers.get('User-Id')

    logging.debug(f"Session key: {session_key}, User ID: {user_id}")
    session_user_id = validate_key(session_key)

    if not session_key or not user_id:
        logging.warning("Missing session key or user ID")
        return jsonify({"error": "El ID de usuario y la clave de sesión son obligatorios"}), 400

    if str(session_user_id) == str(user_id):
        logging.info(f"Valid session for user {user_id}, deleting session")
        delete_session(session_key)
        return jsonify({"message": "Sesión cerrada exitosamente"}), 200
    else:
        logging.warning(f"Invalid session key or user ID for user {user_id}")
        return jsonify({"error": "Clave de sesión o ID de usuario inválidos"}), 400

@users_bp.route('/signUp', methods=['POST'])
def sign_up():
    logging.info("Sign up attempt")
    return "Sign Up"

@users_bp.route('/profilepicture/<int:user_id>', methods=['GET'])
def profile_picture_get(user_id):
    logging.info(f"Fetching profile picture for user {user_id}")
    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        logging.warning(f"Invalid session key for user {user_id}")
        return jsonify({"error": "Invalid session key"}), 400

    query = """
    SELECT FP.ARCHIVO AS archivo FROM USUARIOS U LEFT JOIN FOTOS_PERFIL FP ON U.ID_FOTO = FP.ID_FOTO WHERE U.ID_USUARIO = %s
    """
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        result = cursor.fetchone()
        cursor.close()

        if result:
            archivo = result[0]
            logging.info(f"Profile picture found for user {user_id}")
            return jsonify({"archivo": archivo}), 200
        else:
            logging.warning(f"No profile picture found for user {user_id}")
            return jsonify({"error": "No picture found for the user"}), 404
    except Exception as e:
        logging.error(f"Error fetching profile picture: {e}")
        return jsonify({"error": str(e)}), 500

@users_bp.route('/profilepicture', methods=['PATCH'])
def profile_picture_change():
    logging.info("Profile picture update attempt")
    try:
        data = request.json
        user_id = data.get('user_id')
        path = data.get('path')

        if path is None or user_id is None:
            logging.warning("Missing user ID or picture path")
            return jsonify({"error": "Invalid input data"}), 400

        cursor = cnx.cursor()
        query = """
            UPDATE USUARIOS SET ID_FOTO = (SELECT ID_FOTO FROM FOTOS_PERFIL WHERE ARCHIVO = %s) WHERE ID_USUARIO = %s
        """
        cursor.execute(query, (path, user_id))
        cnx.commit()
        cursor.close()

        logging.info(f"Profile picture updated for user {user_id}")
        return jsonify({"message": "Picture updated successfully"}), 200
    except Exception as e:
        logging.error(f"Error updating profile picture: {e}")
        return jsonify({"error": str(e)}), 500

@users_bp.route('/currentpoints/<int:user_id>', methods=['GET'])
def current_points(user_id):
    logging.info(f"Fetching current points for user {user_id}")
    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        logging.warning(f"Invalid session key for user {user_id}")
        return jsonify({"error": "Llave de sesión inválida."}), 400

    query = "SELECT PU.PUNTOS_ACTUALES AS puntos FROM PUNTOS_USUARIO PU WHERE PU.USUARIO = %s"
    query_nombre = "SELECT NOMBRE FROM USUARIOS WHERE ID_USUARIO = %s"
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query_nombre, (user_id,))
        row = cursor.fetchone()
        nombre = row[0]

        cursor.execute(query, (user_id,))
        result = cursor.fetchone()
        cursor.close()

        if result:
            puntos = int(result[0])
            logging.info(f"User {user_id} has {puntos} points")
            return jsonify({"puntos": puntos, "nombre": nombre}), 200
        else:
            logging.warning(f"No points found for user {user_id}")
            return jsonify({"error": "No points found for the user"}), 404
    except Exception as e:
        logging.error(f"Error fetching points: {e}")
        return jsonify({"error": str(e)}), 500

@users_bp.route('/historypoints/<int:user_id>', methods=['GET'])
def history_points(user_id):
    logging.info(f"Fetching point history for user {user_id}")
    query = """
    SELECT ... FROM HISTORIAL_PUNTOS HP ...
    """
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()

        logging.info(f"History points fetched for user {user_id}")
        return jsonify(results), 200
    except Exception as e:
        logging.error(f"Error fetching point history: {e}")
        return jsonify({"error": str(e)}), 500

# Similar logging additions for updatehistorypoints and updatecurrentpoints...
@users_bp.route('/updatehistorypoints', methods=['POST'])
def update_history_points():
    try:
        data = request.json
        logging.info("Received data for update_history_points: %s", data)

        user_id = data.get('user_id')
        puntos = data.get('puntos')
        tipo = data.get('tipo')
        beneficio_id = data.get('beneficio_id', None)
        evento_id = data.get('evento_id', None)
        reto_id = data.get('reto_id', None)

        if user_id is None or puntos is None or tipo not in [0, 1]:
            logging.error("Invalid input data: user_id=%s, puntos=%s, tipo=%s", user_id, puntos, tipo)
            return jsonify({"error": "Invalid input data"}), 400

        cursor = cnx.cursor()

        queryHistorial = """
        INSERT INTO HISTORIAL_PUNTOS (USUARIO, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, FECHA, BENEFICIO, EVENTO, RETO)
        VALUES (%s, %s, %s, GETDATE(), %s, %s, %s)
        """
        cursor.execute(queryHistorial, (user_id, puntos, tipo, beneficio_id, evento_id, reto_id))
        cnx.commit()
        cursor.close()

        logging.info("History points updated successfully for user_id=%s", user_id)
        return jsonify({"message": "Points updated successfully"}), 200
    except Exception as e:
        logging.error("Error updating history points: %s", str(e))
        return jsonify({"error": str(e)}), 500


@users_bp.route('/updatecurrentpoints', methods=['PATCH'])
def update_current_points():
    try:
        data = request.json
        logging.info("Received data for update_current_points: %s", data)

        user_id = data.get('user_id')
        puntos = data.get('puntos')
        tipo = data.get('tipo')

        if user_id is None or puntos is None or tipo not in [0, 1]:
            logging.error("Invalid input data: user_id=%s, puntos=%s, tipo=%s", user_id, puntos, tipo)
            return jsonify({"error": "Invalid input data"}), 400

        cursor = cnx.cursor()
        if tipo:
            query = """
            UPDATE PUNTOS_USUARIO
            SET PUNTOS_ACTUALES = PUNTOS_ACTUALES + %s
            WHERE USUARIO = %s
            """
        else:
            query = """
            UPDATE PUNTOS_USUARIO
            SET PUNTOS_ACTUALES = PUNTOS_ACTUALES - %s
            WHERE USUARIO = %s
            """
        cursor.execute(query, (puntos, user_id))
        cnx.commit()
        cursor.close()

        logging.info("Current points updated successfully for user_id=%s", user_id)
        return jsonify({"message": "Points updated successfully"}), 200
    except Exception as e:
        logging.error("Error updating current points: %s", str(e))
        return jsonify({"error": str(e)}), 500
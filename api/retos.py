import logging
from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key

from logger import my_logger  


# Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Define Blueprint
retos_bp = Blueprint('retos', __name__)

@retos_bp.route('/getRetos', methods=['GET'])
def get_retos():
    session_key = request.headers.get('key')
    logger.debug(f"Session Key received: {session_key}")

    # Validate session key
    if not session_key or validate_key(session_key) is None:
        logger.warning("Invalid session key.")
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT ID_RETO, NOMBRE, DESCRIPCION, PUNTAJE, CONTACTO, FECHA_LIMITE 
        FROM RETOS;
    """
    
    try:
        logger.debug("Executing query to fetch all retos.")
        cursor = cnx.cursor()
        cursor.execute(query)
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        retos = [dict(zip(columns, result)) for result in results]
        logger.debug(f"Fetched {len(retos)} retos.")
        
        return jsonify(retos), 200
    except Exception as e:
        logger.error(f"Error occurred while fetching retos: {str(e)}")
        return jsonify({"error": str(e)}), 500


@retos_bp.route('/getMyRetos/<int:user_id>', methods=['GET'])
def get_my_retos(user_id):
    session_key = request.headers.get('key')
    logger.debug(f"Session Key received: {session_key}, User ID: {user_id}")
    
    # Validate session key
    if not session_key:
        logger.warning("Missing session key.")
        return jsonify({"error": "Llave de sesión faltante."}), 400

    # Verify session key is valid
    valid_user_id = validate_key(session_key)
    logger.debug(f"Validated user ID from session key: {valid_user_id}")

    if valid_user_id != user_id:
        logger.warning("Session key is invalid for the provided user ID.")
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT R.ID_RETO, R.NOMBRE, R.DESCRIPCION, R.PUNTAJE, R.CONTACTO, R.FECHA_LIMITE 
        FROM RETOS R
        JOIN USUARIOS_RETOS UR ON R.ID_RETO = UR.ID_RETO
        WHERE UR.ID = %s;
    """
    
    try:
        logger.debug("Executing query to fetch user-specific retos.")
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        retos = [dict(zip(columns, result)) for result in results]
        logger.debug(f"Fetched {len(retos)} retos for user ID {user_id}.")
        
        return jsonify(retos), 200
    except Exception as e:
        logger.error(f"Error occurred while fetching user-specific retos: {str(e)}")
        return jsonify({"error": str(e)}), 500


@retos_bp.route('/registerReto', methods=['POST'])
def register_reto():
    session_key = request.headers.get('key')
    logger.debug(f"Session Key received: {session_key}")
    
    # Validate session key
    if not session_key:
        logger.warning("Missing session key.")
        return jsonify({"error": "Llave de sesión faltante."}), 400

    valid_user_id = validate_key(session_key)
    
    # Verify session key is valid
    if valid_user_id is None:
        logger.warning("Invalid session key.")
        return jsonify({"error": "Llave de sesión inválida."}), 400

    data = request.json
    user_id = data.get('user_id')
    id_reto = data.get('id_reto')

    logger.debug(f"Received user_id: {user_id}, id_reto: {id_reto}")
    
    # Validate request data
    if not user_id or not id_reto:
        logger.warning("Missing user_id or id_reto in request.")
        return jsonify({"error": "Faltan datos necesarios (user_id o id_reto)."}), 400

    # Check if user_id matches session user_id
    if valid_user_id != user_id:
        logger.warning("User ID does not match session.")
        return jsonify({"error": "El ID de usuario no coincide con la sesión."}), 400
    
    query = """
        INSERT INTO USUARIOS_RETOS (ID, ID_RETO)
        VALUES (%s, %s);
    """
    
    try:
        logger.debug(f"Registering user ID {user_id} to reto ID {id_reto}.")
        cursor = cnx.cursor()
        cursor.execute(query, (user_id, id_reto))
        cnx.commit()
        cursor.close()
        
        logger.debug(f"User ID {user_id} registered to reto ID {id_reto} successfully.")
        return jsonify({"message": "Usuario registrado al reto exitosamente."}), 200
    except Exception as e:
        logger.error(f"Error occurred while registering user to reto: {str(e)}")
        return jsonify({"error": str(e)}), 500
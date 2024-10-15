from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key

from logger import my_logger  



# Define Blueprint
retos_bp = Blueprint('retos', __name__)

@retos_bp.route('/getRetos', methods=['GET'])
def get_retos():
    """
    Obtiene todos los retos disponibles.
    Documentado por Carlos
    ---
    tags:
      - Sprint 3
    parameters:
      - in: header
        name: key
        type: string
        required: true
        description: Clave de sesión del usuario.
        example: "abcd1234sessionkey"
    responses:
      200:
        description: Retos devueltos con éxito.
        schema:
          type: array
          items:
            type: object
            properties:
              ID_RETO:
                type: integer
                example: 1
              NOMBRE:
                type: string
                example: "Reto de Solidaridad"
              DESCRIPCION:
                type: string
                example: "Descripción del reto."
              PUNTAJE:
                type: integer
                example: 100
              CONTACTO:
                type: string
                example: "contacto@ejemplo.com"
              FECHA_LIMITE:
                type: string
                example: "2024-12-31"
      400:
        description: Llave de sesión inválida.
      500:
        description: Error interno del servidor.
    """
    session_key = request.headers.get('key')
    my_logger.debug(f"Session Key received: {session_key}")

    # Validate session key
    if not session_key or validate_key(session_key) is None:
        my_logger.warning("Invalid session key.")
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT ID_RETO, NOMBRE, DESCRIPCION, PUNTAJE, CONTACTO, FECHA_LIMITE 
        FROM RETOS;
    """
    
    try:
        my_logger.debug("Executing query to fetch all retos.")
        cursor = cnx.cursor()
        cursor.execute(query)
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        retos = [dict(zip(columns, result)) for result in results]
        my_logger.debug(f"Fetched {len(retos)} retos.")
        
        return jsonify(retos), 200
    except Exception as e:
        my_logger.error(f"Error occurred while fetching retos: {str(e)}")
        return jsonify({"error": str(e)}), 500


@retos_bp.route('/getMyRetos/<int:user_id>', methods=['GET'])
def get_my_retos(user_id):
    """
    Obtiene los retos específicos de un usuario.
    Documentado por Carlos
    ---
    tags:
      - Sprint 3
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario para obtener sus retos.
        example: 123
      - in: header
        name: key
        type: string
        required: true
        description: Clave de sesión del usuario.
        example: "abcd1234sessionkey"
    responses:
      200:
        description: Retos del usuario devueltos con éxito.
        schema:
          type: array
          items:
            type: object
            properties:
              ID_RETO:
                type: integer
                example: 1
              NOMBRE:
                type: string
                example: "Reto de Solidaridad"
              DESCRIPCION:
                type: string
                example: "Descripción del reto."
              PUNTAJE:
                type: integer
                example: 100
              CONTACTO:
                type: string
                example: "contacto@ejemplo.com"
              FECHA_LIMITE:
                type: string
                example: "2024-12-31"
      400:
        description: Llave de sesión inválida o faltante.
      500:
        description: Error interno del servidor.
    """
    session_key = request.headers.get('key')
    my_logger.debug(f"Session Key received: {session_key}, User ID: {user_id}")
    
    # Validate session key
    if not session_key:
        my_logger.warning("Missing session key.")
        return jsonify({"error": "Llave de sesión faltante."}), 400

    # Verify session key is valid
    valid_user_id = validate_key(session_key)
    my_logger.debug(f"Validated user ID from session key: {valid_user_id}")

    if valid_user_id != user_id:
        my_logger.warning("Session key is invalid for the provided user ID.")
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT R.ID_RETO, R.NOMBRE, R.DESCRIPCION, R.PUNTAJE, R.CONTACTO, R.FECHA_LIMITE 
        FROM RETOS R
        JOIN USUARIOS_RETOS UR ON R.ID_RETO = UR.ID_RETO
        WHERE UR.ID = %s;
    """
    
    try:
        my_logger.debug("Executing query to fetch user-specific retos.")
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        retos = [dict(zip(columns, result)) for result in results]
        my_logger.debug(f"Fetched {len(retos)} retos for user ID {user_id}.")
        
        return jsonify(retos), 200
    except Exception as e:
        my_logger.error(f"Error occurred while fetching user-specific retos: {str(e)}")
        return jsonify({"error": str(e)}), 500


@retos_bp.route('/registerReto', methods=['POST'])
def register_reto():
    """
    Registra a un usuario en un reto específico.
    Documentado por Carlos
    ---
    tags:
      - Sprint 3
    parameters:
      - in: header
        name: key
        type: string
        required: true
        description: Clave de sesión del usuario.
        example: "abcd1234sessionkey"
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            user_id:
              type: integer
              description: ID del usuario que se quiere registrar.
              example: 123
            id_reto:
              type: integer
              description: ID del reto en el que se quiere registrar al usuario.
              example: 456
    responses:
      200:
        description: Usuario registrado exitosamente en el reto.
      400:
        description: Llave de sesión inválida, faltante, o datos faltantes.
      500:
        description: Error interno del servidor.
    """
    session_key = request.headers.get('key')
    my_logger.debug(f"Session Key received: {session_key}")
    
    # Validate session key
    if not session_key:
        my_logger.warning("Missing session key.")
        return jsonify({"error": "Llave de sesión faltante."}), 400

    valid_user_id = validate_key(session_key)
    
    # Verify session key is valid
    if valid_user_id is None:
        my_logger.warning("Invalid session key.")
        return jsonify({"error": "Llave de sesión inválida."}), 400

    data = request.json
    user_id = data.get('user_id')
    id_reto = data.get('id_reto')

    my_logger.debug(f"Received user_id: {user_id}, id_reto: {id_reto}")
    
    # Validate request data
    if not user_id or not id_reto:
        my_logger.warning("Missing user_id or id_reto in request.")
        return jsonify({"error": "Faltan datos necesarios (user_id o id_reto)."}), 400

    # Check if user_id matches session user_id
    if valid_user_id != user_id:
        my_logger.warning("User ID does not match session.")
        return jsonify({"error": "El ID de usuario no coincide con la sesión."}), 400
    
    query = """
        INSERT INTO USUARIOS_RETOS (ID, ID_RETO)
        VALUES (%s, %s);
    """
    
    try:
        my_logger.debug(f"Registering user ID {user_id} to reto ID {id_reto}.")
        cursor = cnx.cursor()
        cursor.execute(query, (user_id, id_reto))
        cnx.commit()
        cursor.close()
        
        my_logger.debug(f"User ID {user_id} registered to reto ID {id_reto} successfully.")
        return jsonify({"message": "Usuario registrado al reto exitosamente."}), 200
    except Exception as e:
        my_logger.error(f"Error occurred while registering user to reto: {str(e)}")
        return jsonify({"error": str(e)}), 500
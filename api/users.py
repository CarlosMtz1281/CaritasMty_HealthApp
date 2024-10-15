from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import create_session, validate_key, delete_session
import hashlib

from logger import my_logger  



users_bp = Blueprint('users', __name__)

@users_bp.route('/login', methods=['POST'])
def login():
    """
    Maneja el inicio de sesión de un usuario.
    Documentado por Nico.
    ---
    tags:
      - Sprint 2
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            correo:
              type: string
              description: El correo electrónico del usuario.
              example: "juan.perez@example.com"
            password:
              type: string
              description: La contraseña del usuario.
              example: "password123"
    responses:
      200:
        description: Inicio de sesión exitoso.
        schema:
          type: object
          properties:
            user_id:
              type: integer
              description: ID del usuario que ha iniciado sesión.
              example: 123
            key:
              type: string
              description: Clave de sesión generada para el usuario.
              example: "abcd1234sessionkey"
            tags:
              type: array
              items:
                type: object
                properties:
                  nombre:
                    type: string
                    description: Nombre del tag.
                    example: "Solidaridad"
                  veces_usado:
                    type: integer
                    description: Veces que el tag ha sido usado por el usuario.
                    example: 5
      400:
        description: Error en la solicitud por falta de datos o credenciales inválidas.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "El correo y la contraseña son obligatorios. O Credenciales inválidas"
      500:
        description: Error interno del servidor.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Mensaje detallando el error"
    """

    my_logger.info("Login attempt started")

    data = request.json
    correo = data.get('correo')
    password = data.get('password')

    if not correo or not password:
        my_logger.warning("Missing email or password in request")
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
            my_logger.warning(f"Invalid credentials for user: {correo}")
            return jsonify({"error": "Credenciales inválidas"}), 400

        user_id = results[0]['user_id']
        my_logger.info(f"User {user_id} logged in successfully")
    except Exception as e:
        my_logger.error(f"Error during login: {e}")
        return jsonify({"error": str(e)}), 500

    # Crear la sesión del usuario
    session_key = create_session(user_id)
    my_logger.info(f"Session created for user {user_id} with key {session_key}")

    # Obtener los tags asociados al usuario y las veces que han sido usados
    query_tags = """
    SELECT T.NOMBRE, UT.VECES_USADO
    FROM USUARIOS_TAGS UT
    JOIN TAGS T ON UT.ID_TAG = T.ID_TAG
    WHERE UT.ID_USUARIO = %s
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query_tags, (user_id,))
        user_tags = [{"nombre": row[0], "veces_usado": row[1]} for row in cursor.fetchall()]
        cursor.close()

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    # Responder con el user_id, la clave de sesión y los tags del usuario con las veces usados
    return jsonify({"user_id": user_id, "key": session_key, "tags": user_tags}), 200


@users_bp.route('/signOut', methods=['POST'])
def sign_out():
    my_logger.info("Sign out attempt started")
    session_key = request.headers.get('key')
    user_id = request.headers.get('User-Id')

    my_logger.debug(f"Session key: {session_key}, User ID: {user_id}")
    session_user_id = validate_key(session_key)

    if not session_key or not user_id:
        my_logger.warning("Missing session key or user ID")
        return jsonify({"error": "El ID de usuario y la clave de sesión son obligatorios"}), 400

    if str(session_user_id) == str(user_id):
        my_logger.info(f"Valid session for user {user_id}, deleting session")
        delete_session(session_key)
        return jsonify({"message": "Sesión cerrada exitosamente"}), 200
    else:
        my_logger.warning(f"Invalid session key or user ID for user {user_id}")
        return jsonify({"error": "Clave de sesión o ID de usuario inválidos"}), 400

@users_bp.route('/signUp', methods=['POST'])
def sign_up():
    my_logger.info("Sign up attempt")
    return "Sign Up"

@users_bp.route('/profilepicture/<int:user_id>', methods=['GET'])
def profile_picture_get(user_id):
    my_logger.info(f"Fetching profile picture for user {user_id}")
    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        my_logger.warning(f"Invalid session key for user {user_id}")
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
            my_logger.info(f"Profile picture found for user {user_id}")
            return jsonify({"archivo": archivo}), 200
        else:
            my_logger.warning(f"No profile picture found for user {user_id}")
            return jsonify({"error": "No picture found for the user"}), 404
    except Exception as e:
        my_logger.error(f"Error fetching profile picture: {e}")
        return jsonify({"error": str(e)}), 500

@users_bp.route('/profilepicture', methods=['PATCH'])
def profile_picture_change():
    my_logger.info("Profile picture update attempt")
    try:
        data = request.json
        user_id = data.get('user_id')
        path = data.get('path')

        if path is None or user_id is None:
            my_logger.warning("Missing user ID or picture path")
            return jsonify({"error": "Invalid input data"}), 400

        cursor = cnx.cursor()
        query = """
            UPDATE USUARIOS SET ID_FOTO = (SELECT ID_FOTO FROM FOTOS_PERFIL WHERE ARCHIVO = %s) WHERE ID_USUARIO = %s
        """
        cursor.execute(query, (path, user_id))
        cnx.commit()
        cursor.close()

        my_logger.info(f"Profile picture updated for user {user_id}")
        return jsonify({"message": "Picture updated successfully"}), 200
    except Exception as e:
        my_logger.error(f"Error updating profile picture: {e}")
        return jsonify({"error": str(e)}), 500

@users_bp.route('/currentpoints/<int:user_id>', methods=['GET'])
def current_points(user_id):
    my_logger.info(f"Fetching current points for user {user_id}")
    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        my_logger.warning(f"Invalid session key for user {user_id}")
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
            my_logger.info(f"User {user_id} has {puntos} points")
            return jsonify({"puntos": puntos, "nombre": nombre}), 200
        else:
            my_logger.warning(f"No points found for user {user_id}")
            return jsonify({"error": "No points found for the user"}), 404
    except Exception as e:
        my_logger.error(f"Error fetching points: {e}")
        return jsonify({"error": str(e)}), 500

@users_bp.route('/historypoints/<int:user_id>', methods=['GET'])
def history_points(user_id):
    my_logger.info(f"Fetching point history for user {user_id}")
    query = """
    SELECT
        U.ID_USUARIO AS user_id,
        U.NOMBRE AS nombre,
        HP.PUNTOS_MODIFICADOS AS puntos,
        HP.TIPO_MODIFICACION AS tipo,
        HP.FECHA AS fecha,
        COALESCE(B.NOMBRE , E.NOMBRE, R.NOMBRE) AS origen_nombre,
        COALESCE(B.ID_BENEFICIO , E.ID_EVENTO, R.ID_RETO) AS origen_id,
        CASE
            WHEN HP.BENEFICIO IS NOT NULL THEN 'Beneficio'
            WHEN HP.EVENTO IS NOT NULL THEN 'Evento'
            WHEN HP.RETO IS NOT NULL THEN 'Reto'
        END AS origen_tipo
    FROM
        HISTORIAL_PUNTOS HP
        INNER JOIN USUARIOS U ON HP.USUARIO = U.ID_USUARIO
        LEFT JOIN BENEFICIOS B ON HP.BENEFICIO = B.ID_BENEFICIO
        LEFT JOIN EVENTOS E ON HP.EVENTO = E.ID_EVENTO
        LEFT JOIN RETOS R ON HP.RETO = R.ID_RETO
    WHERE
        U.ID_USUARIO = %s
    """

    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()

        my_logger.info(f"History points fetched for user {user_id}")
        return jsonify(results), 200
    except Exception as e:
        my_logger.error(f"Error fetching point history: {e}")
        return jsonify({"error": str(e)}), 500

# Similar my_logger additions for updatehistorypoints and updatecurrentpoints...
@users_bp.route('/updatehistorypoints', methods=['POST'])
def update_history_points():
    try:
        data = request.json
        my_logger.info("Received data for update_history_points: %s", data)

        user_id = data.get('user_id')
        puntos = data.get('puntos')
        tipo = data.get('tipo')
        beneficio_id = data.get('beneficio_id', None)
        evento_id = data.get('evento_id', None)
        reto_id = data.get('reto_id', None)

        if user_id is None or puntos is None or tipo not in [0, 1]:
            my_logger.error("Invalid input data: user_id=%s, puntos=%s, tipo=%s", user_id, puntos, tipo)
            return jsonify({"error": "Invalid input data"}), 400

        cursor = cnx.cursor()

        queryHistorial = """
        INSERT INTO HISTORIAL_PUNTOS (USUARIO, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, FECHA, BENEFICIO, EVENTO, RETO)
        VALUES (%s, %s, %s, GETDATE(), %s, %s, %s)
        """
        cursor.execute(queryHistorial, (user_id, puntos, tipo, beneficio_id, evento_id, reto_id))
        cnx.commit()
        cursor.close()

        my_logger.info("History points updated successfully for user_id=%s", user_id)
        return jsonify({"message": "Points updated successfully"}), 200
    except Exception as e:
        my_logger.error("Error updating history points: %s", str(e))
        return jsonify({"error": str(e)}), 500


@users_bp.route('/updatecurrentpoints', methods=['PATCH'])
def update_current_points():
    try:
        data = request.json
        my_logger.info("Received data for update_current_points: %s", data)

        user_id = data.get('user_id')
        puntos = data.get('puntos')
        tipo = data.get('tipo')

        if user_id is None or puntos is None or tipo not in [0, 1]:
            my_logger.error("Invalid input data: user_id=%s, puntos=%s, tipo=%s", user_id, puntos, tipo)
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

        my_logger.info("Current points updated successfully for user_id=%s", user_id)
        return jsonify({"message": "Points updated successfully"}), 200
    except Exception as e:

        my_logger.error("Error updating current points: %s", str(e))
        return jsonify({"error": str(e)}), 500

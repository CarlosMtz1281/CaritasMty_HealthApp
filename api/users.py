from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import create_session, validate_key, delete_session

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
    data = request.json
    correo = data.get('correo')
    password = data.get('password')

    if not correo or not password:
        return jsonify({"error": "El correo y la contraseña son requeridos"}), 400

    query = """
    SELECT
        U.ID_USUARIO AS user_id
    FROM
        USUARIOS U
    WHERE
        U.CORREO = ?
        AND U.PASS = ?
    """

    try:
        cursor = cnx.cursor()
        cursor.execute(query, (correo, password))

        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()

        if not results:
            return jsonify({"error": "Credenciales inválidas"}), 400

        user_id = results[0]['user_id']

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    session_key = create_session(user_id)

    return jsonify({"user_id": user_id, "key": session_key}), 200


@users_bp.route('/signOut', methods=['POST'])
def sign_out():

    """
    Maneja el cierre de sesión de un usuario.
    Documentado por Iván.
    ---
    tags:
      - Sprint 2
    parameters:
      - name: key
        in: header
        type: string
        required: true
        description: Clave de sesión para autenticar la solicitud.
      - name: User-Id
        in: header
        type: string
        required: true
        description: ID del usuario que está cerrando sesión.
    responses:
      200:
        description: Cierre de sesión exitoso.
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Sesión cerrada exitosamente"
      400:
        description: Error en la solicitud, faltan o son inválidos el ID de usuario o la clave de sesión.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "El ID de usuario y la clave de sesión son obligatorios. O Clave de sesión o ID de usuario inválidos"
    """

    session_key = request.headers.get('key')
    user_id = request.headers.get('User-Id')

    print("Session key: ", session_key)
    print("User ID from request: ", user_id)

    session_user_id = validate_key(session_key)

    print("User ID from session: ", session_user_id)

    if not session_key or not user_id:
        print("No session key or user ID")
        return jsonify({"error": "El ID de usuario y la clave de sesión son obligatorios"}), 400

    if str(session_user_id) == str(user_id):
        print("Deleting session ", session_key)
        delete_session(session_key)
        return jsonify({"message": "Sesión cerrada exitosamente"}), 200
    else:
        print("Invalid session key or user ID")
        return jsonify({"error": "Clave de sesión o ID de usuario inválidos"}), 400


@users_bp.route('/signUp', methods=['POST'])
def sign_up():
    return "Sign Up"

@users_bp.route('/profilepicture/<int:user_id>', methods=['GET'])
def profile_picture_get(user_id):
    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        return jsonify({"error": "Invalid session key"}), 400

    query = """
    SELECT
        FP.ARCHIVO AS archivo
    FROM
        USUARIOS U
    LEFT JOIN
        FOTOS_PERFIL FP ON U.ID_FOTO = FP.ID_FOTO
    WHERE
        U.ID_USUARIO = ?
    """
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))

        result = cursor.fetchone()
        cursor.close()

        if result:
            archivo = result[0]
            return jsonify({"archivo": archivo}), 200
        else:
            return jsonify({"error": "No points found for the user"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@users_bp.route('/profilepicture', methods=['PATCH'])
def profile_picture_change():
    try:
        data = request.json

        user_id = data.get('user_id')
        path = data.get('path')

        if path is None or user_id is None:
            return jsonify({"error": "Invalid input data"}), 400

        cursor = cnx.cursor()
        query = """
            UPDATE USUARIOS
            SET ID_FOTO = (SELECT ID_FOTO FROM FOTOS_PERFIL WHERE ARCHIVO = %s)
            WHERE ID_USUARIO = %s
            """
        cursor.execute(query, (path, user_id))

        cnx.commit()

        cursor.close()

        return jsonify({"message": "Points updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@users_bp.route('/currentpoints/<int:user_id>', methods=['GET'])
def current_points(user_id):
    """
    Consulta los puntos actuales de un usuario.
    Documentado por German.
    ---
    tags:
      - Sprint 2
    parameters:
      - name: user_id
        in: path
        type: integer
        required: true
        description: El ID del usuario.
      - name: key
        in: header
        type: string
        required: true
        description: Clave de sesión para autenticar la solicitud.
    responses:
      200:
        description: Devuelve los puntos actuales del usuario.
        schema:
          type: object
          properties:
            puntos:
              type: integer
              example: 120
      400:
        description: Clave de sesión inválida o faltante.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Llave de sesión inválida"
      404:
        description: No se encontraron puntos para el usuario.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "No se encontraron puntos para el usuario"
      500:
        description: Error interno del servidor.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Mensaje de error"
    """

    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        return jsonify({"error": "Llave de sesión inválida."}), 400

    query = """
    SELECT
        PU.PUNTOS_ACTUALES AS puntos
    FROM
        PUNTOS_USUARIO PU
    WHERE
        PU.USUARIO = ?
    """

    query_nombre = """
    SELECT NOMBRE FROM USUARIOS WHERE ID_USUARIO = ?
    """
    try:
        #obtener nombre
        cursor = cnx.cursor()
        cursor.execute(query_nombre, (user_id))
        row = cursor.fetchone()
        nombre= row[0]


        #obtener puntos
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))

        columns = [column[0] for column in cursor.description]

        result = cursor.fetchone()
        cursor.close()

        if result:
            puntos = int(result[columns.index('puntos')])
            return jsonify({"puntos": puntos, "nombre": nombre}), 200
        else:
            return jsonify({"error": "No se encontraron puntos para el usuario."}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@users_bp.route('/historypoints/<int:user_id>', methods=['GET'])
def history_points(user_id):
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

        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@users_bp.route('/updatehistorypoints', methods=['POST'])
def update_history_points():
    try:
        data = request.json

        user_id = data.get('user_id')
        puntos = data.get('puntos')
        tipo = data.get('tipo')
        beneficio_id = data.get('beneficio_id', None)
        evento_id = data.get('evento_id', None)
        reto_id = data.get('reto_id', None)

        if user_id is None or puntos is None or tipo not in [0, 1]:
            return jsonify({"error": "Invalid input data"}), 400

        cursor = cnx.cursor()

        queryHistorial = """
        INSERT INTO HISTORIAL_PUNTOS (USUARIO, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, FECHA, BENEFICIO, EVENTO, RETO)
        VALUES (%s, %s, %s, GETDATE(), %s, %s, %s)
        """
        cursor.execute(queryHistorial, (user_id, puntos, tipo, beneficio_id, evento_id, reto_id))

        cnx.commit()

        cursor.close()

        return jsonify({"message": "Points updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@users_bp.route('/updatecurrentpoints', methods=['PATCH'])
def update_current_points():
    try:
        data = request.json

        user_id = data.get('user_id')
        puntos = data.get('puntos')
        tipo = data.get('tipo')

        if user_id is None or puntos is None or tipo not in [0, 1]:
            return jsonify({"error": "Invalid input data"}), 400

        cursor = cnx.cursor()
        query = ""
        if(tipo):
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

        return jsonify({"message": "Points updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
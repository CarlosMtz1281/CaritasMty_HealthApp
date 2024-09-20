from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import create_session, validate_key, delete_session

users_bp = Blueprint('users', __name__)



@users_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    correo = data.get('correo')
    password = data.get('password')

    if not correo or not password:
        return jsonify({"error": "User ID is required"}), 400

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
            return jsonify({"error": "Invalid credentials"}), 400

        user_id = results[0]['user_id']
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
    user_id = results[0]['user_id']
    
    session_key = create_session(user_id)
    
    return jsonify({"key": session_key}), 200

@users_bp.route('/signOut', methods=['POST'])
def sign_out():
    session_key = request.headers.get('key')
    if session_key and validate_key(session_key):
        delete_session(session_key)
        return jsonify({"message": "Signed out successfully"}), 200
    return jsonify({"error": "Invalid session key"}), 400

@users_bp.route('/signUp', methods=['POST'])
def sign_up():
    return "Sign Up"

@users_bp.route('/currentpoints/<int:user_id>', methods=['GET'])
def current_points(user_id):
    session_key = request.headers.get('key')
    
    if not session_key or validate_key(session_key) != user_id:
        return jsonify({"error": "Invalid session key"}), 400
    
    query = """
    SELECT
        PU.PUNTOS_ACTUALES AS puntos
    FROM
        PUNTOS_USUARIO PU
    WHERE
        PU.USUARIO = ?
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
        U.ID_USUARIO = ?
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
        VALUES (?, ?, ?, GETDATE(), ?, ?, ?)
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
            SET PUNTOS_ACTUALES = PUNTOS_ACTUALES + ?
            WHERE USUARIO = ?
            """
        else:
            query = """
            UPDATE PUNTOS_USUARIO
            SET PUNTOS_ACTUALES = PUNTOS_ACTUALES - ?
            WHERE USUARIO = ?
            """
        cursor.execute(query, (puntos, user_id))

        cnx.commit()

        cursor.close()
        
        return jsonify({"message": "Points updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
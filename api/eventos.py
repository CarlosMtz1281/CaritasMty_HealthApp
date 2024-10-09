from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key

from logger import my_logger  

eventos_bp = Blueprint('eventos', __name__)

@eventos_bp.route('/getFuturosEventos', methods=['GET'])
def eventos():
    # Log the request for this endpoint
    my_logger.info(f"({request.remote_addr}) Requested /getFuturosEventos")

    query = """
        SELECT ID_EVENTO, NOMBRE, DESCRIPCION, NUM_MAX_ASISTENTES, PUNTAJE, FECHA, LUGAR, EXPOSITOR
        FROM EVENTOS
        WHERE FECHA >= GETDATE();
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query)
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()

        # Log success after fetching data
        my_logger.info(f"({request.remote_addr}) Successfully fetched future events.")
        
        eventos = []
        for result in results:
            evento = dict(zip(columns, result))
            eventos.append(evento)
        
        return jsonify(eventos), 200
    except Exception as e:
        # Log the error if an exception occurs
        my_logger.error(f"({request.remote_addr}) Error fetching future events: {str(e)}")
        return jsonify({"error": str(e)}), 500
    

@eventos_bp.route('/eventosUsuario/<int:user_id>', methods=['GET'])
def eventos_usuario(user_id):
    session_key = request.headers.get('key')

    # Log the request
    my_logger.info(f"({request.remote_addr}) Requested /eventosUsuario/{user_id}")

    if not session_key:
        my_logger.warning(f"({request.remote_addr}) Missing session key.")
        return jsonify({"error": "Llave de sesión faltante."}), 400

    valid_user_id = validate_key(session_key)

    if valid_user_id != user_id:
        my_logger.warning(f"({request.remote_addr}) Invalid session key for user {user_id}.")
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT E.ID_EVENTO, E.NOMBRE, E.DESCRIPCION, E.NUM_MAX_ASISTENTES, E.PUNTAJE, E.FECHA, E.LUGAR, E.EXPOSITOR
        FROM USUARIOS_EVENTOS UE
        JOIN EVENTOS E ON UE.EVENTO = E.ID_EVENTO
        WHERE UE.USUARIO = %d AND E.FECHA >= GETDATE();
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        my_logger.info(f"({request.remote_addr}) Successfully fetched events for user {user_id}.")
        
        eventos = []
        for result in results:
            evento = dict(zip(columns, result))
            eventos.append(evento)
        
        return jsonify(eventos), 200
    except Exception as e:
        my_logger.error(f"({request.remote_addr}) Error fetching events for user {user_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500
    

@eventos_bp.route('/usuariosEvento/<int:user_id>/<int:id_evento>', methods=['GET'])
def usuarios_evento(user_id, id_evento):
    session_key = request.headers.get('key')

    my_logger.info(f"({request.remote_addr}) Requested /usuariosEvento/{user_id}/{id_evento}")

    if not session_key or validate_key(session_key) != user_id:
        my_logger.warning(f"({request.remote_addr}) Invalid session key for user {user_id}.")
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT U.NOMBRE, U.A_PATERNO
        FROM USUARIOS_EVENTOS UE
        JOIN USUARIOS U ON UE.USUARIO = U.ID_USUARIO
        WHERE UE.EVENTO = %d AND U.ID_USUARIO != %d;
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (id_evento, user_id))
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        my_logger.info(f"({request.remote_addr}) Successfully fetched users for event {id_evento}.")
        
        usuarios = []
        for result in results:
            usuario = dict(zip(columns, result))
            usuarios.append(usuario)
        
        return jsonify(usuarios), 200
    except Exception as e:
        my_logger.error(f"({request.remote_addr}) Error fetching users for event {id_evento}: {str(e)}")
        return jsonify({"error": str(e)}), 500
    

@eventos_bp.route('/registrarParticipacion', methods=['POST'])
def registrar_participacion():
    session_key = request.headers.get('key')
    
    data = request.json
    user_id = data.get('user_id')
    id_evento = data.get('id_evento')
    
    my_logger.info(f"({request.remote_addr}) Requested /registrarParticipacion for user {user_id} in event {id_evento}")

    query = """
        INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO, ASISTIO)
        VALUES (%d, %d, 0);
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id, id_evento))
        cnx.commit()
        cursor.close()
        
        my_logger.info(f"({request.remote_addr}) Successfully registered participation for user {user_id} in event {id_evento}.")
        
        return jsonify({"message": "Participación registrada."}), 200
    except Exception as e:
        my_logger.error(f"({request.remote_addr}) Error registering participation for user {user_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500
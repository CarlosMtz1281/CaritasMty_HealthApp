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
        SELECT E.ID_EVENTO, E.NOMBRE, E.DESCRIPCION, E.NUM_MAX_ASISTENTES, E.PUNTAJE, E.FECHA, E.LUGAR, E.EXPOSITOR,
               STRING_AGG(T.NOMBRE, ', ') AS TAGS
        FROM EVENTOS E
        LEFT JOIN EVENTOS_TAGS ET ON E.ID_EVENTO = ET.ID_EVENTO
        LEFT JOIN TAGS T ON ET.ID_TAG = T.ID_TAG
        WHERE E.FECHA >= GETDATE()
        GROUP BY E.ID_EVENTO, E.NOMBRE, E.DESCRIPCION, E.NUM_MAX_ASISTENTES, E.PUNTAJE, E.FECHA, E.LUGAR, E.EXPOSITOR;
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
        SELECT E.ID_EVENTO, E.NOMBRE, E.DESCRIPCION, E.NUM_MAX_ASISTENTES, E.PUNTAJE, E.FECHA, E.LUGAR, E.EXPOSITOR,
               STRING_AGG(T.NOMBRE, ', ') AS TAGS
        FROM USUARIOS_EVENTOS UE
        JOIN EVENTOS E ON UE.EVENTO = E.ID_EVENTO
        LEFT JOIN EVENTOS_TAGS ET ON E.ID_EVENTO = ET.ID_EVENTO
        LEFT JOIN TAGS T ON ET.ID_TAG = T.ID_TAG
        WHERE UE.USUARIO = %s AND E.FECHA >= GETDATE()
        GROUP BY E.ID_EVENTO, E.NOMBRE, E.DESCRIPCION, E.NUM_MAX_ASISTENTES, E.PUNTAJE, E.FECHA, E.LUGAR, E.EXPOSITOR;
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
    # Query para registrar la participación en USUARIOS_EVENTOS
    query_participacion = """

        INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO, ASISTIO)
        VALUES (%s, %s, 0);
    """
    
    # Query para obtener los tags del evento
    query_tags_evento = """
        SELECT ID_TAG
        FROM EVENTOS_TAGS
        WHERE ID_EVENTO = %s;
    """
    
    # Query para actualizar los tags del usuario (incrementar veces usado si ya existe)
    query_update_tag = """
        UPDATE USUARIOS_TAGS
        SET VECES_USADO = VECES_USADO + 1
        WHERE ID_USUARIO = %s AND ID_TAG = %s;
    """
    
    # Query para insertar un nuevo tag en USUARIOS_TAGS si no existe
    query_insert_tag = """
        INSERT INTO USUARIOS_TAGS (ID_USUARIO, ID_TAG, VECES_USADO)
        VALUES (%s, %s, 1);
    """
    
    try:
        cursor = cnx.cursor()
        
        # 1. Registrar la participación en el evento
        cursor.execute(query_participacion, (user_id, id_evento))
        
        # 2. Obtener los tags asociados al evento
        cursor.execute(query_tags_evento, (id_evento,))
        event_tags = cursor.fetchall()
        
        # 3. Actualizar los tags del usuario
        for tag in event_tags:
            id_tag = tag[0]
            
            # Intentar actualizar el tag del usuario (si ya lo tiene)
            rows_affected = cursor.execute(query_update_tag, (user_id, id_tag))
            
            # Si no se actualizó ninguna fila, significa que el usuario no tiene ese tag, así que lo insertamos
            if cursor.rowcount == 0:
                cursor.execute(query_insert_tag, (user_id, id_tag))
        
        # Confirmar los cambios en la base de datos
        cnx.commit()
        cursor.close()
        
        my_logger.info(f"({request.remote_addr}) Successfully registered participation for user {user_id} in event {id_evento}.")

        return jsonify({"message": "Participación registrada y tags actualizados."}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    
    
@eventos_bp.route('/asistirEvento', methods=['POST'])
def asistir_evento():    
    data = request.json
    user_id = data.get('user_id')
    id_evento = data.get('id_evento')
    
    # primero validar que usuario este registrado en el evento
    query = """
        SELECT *
        FROM USUARIOS_EVENTOS
        WHERE USUARIO = %d AND EVENTO = %d;
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id, id_evento))
        result = cursor.fetchone()
        cursor.close()

        if not result:
            return jsonify({"error": "Usuario no registrado en el evento."}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
    # si el usuario ya asistió, no hacer nada
    if result[2]:
        return jsonify({"message": "Usuario ya asistió al evento."}), 200
    
    # si el usuario no ha asistido, actualizar el registro
    query = """
        UPDATE USUARIOS_EVENTOS
        SET ASISTIO = 1
        WHERE USUARIO = %d AND EVENTO = %d;
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id, id_evento))
        cnx.commit()
        cursor.close()
        
        return jsonify({"message": "Asistencia registrada."}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    

@eventos_bp.route('/crearEvento', methods=['POST'])
def crear_evento():
    return "Crear Evento"



@eventos_bp.route('/qr', methods=['GET'])
def qr():
    return "QR Endpoint"

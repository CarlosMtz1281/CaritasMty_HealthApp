from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key


eventos_bp = Blueprint('eventos', __name__)

@eventos_bp.route('/getFuturosEventos', methods=['GET'])
def eventos():
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
        
        eventos = []
        for result in results:
            evento = dict(zip(columns, result))
            eventos.append(evento)
        
        return jsonify(eventos), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    

@eventos_bp.route('/eventosUsuario/<int:user_id>', methods=['GET'])
def eventos_usuario(user_id):
    session_key = request.headers.get('key')

    # Mensaje de depuración para la sesión
    print(f"Session Key received: {session_key}")
    print(f"User ID received: {user_id}")
    
    # Validar la sesión
    if not session_key:
        print("Session key is missing.")
        return jsonify({"error": "Llave de sesión faltante."}), 400

    # Verificar si la clave es válida
    valid_user_id = validate_key(session_key)
    print(f"Valid user ID from session key: {valid_user_id}")

    if valid_user_id != user_id:
        print("Invalid session key for the provided user ID.")
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT E.ID_EVENTO, E.NOMBRE, E.DESCRIPCION, E.NUM_MAX_ASISTENTES, E.PUNTAJE, E.FECHA, E.LUGAR, E.EXPOSITOR
        FROM USUARIOS_EVENTOS UE
        JOIN EVENTOS E ON UE.EVENTO = E.ID_EVENTO
        WHERE UE.USUARIO = %s AND E.FECHA >= GETDATE();
    """
    
    try:
        # Depurar antes de ejecutar la consulta
        print("Attempting to execute query.")
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        
        # Depurar el estado del cursor
        print("Query executed successfully.")
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        # Depurar resultados obtenidos
        print(f"Fetched {len(results)} events.")
        
        eventos = []
        for result in results:
            evento = dict(zip(columns, result))
            eventos.append(evento)
        
        return jsonify(eventos), 200
    except Exception as e:
        # Depurar en caso de error
        print(f"An error occurred: {str(e)}")
        return jsonify({"error": str(e)}), 500
    
    

@eventos_bp.route('/usuariosEvento/<int:user_id>/<int:id_evento>', methods=['GET'])
def usuarios_evento(user_id, id_evento):
    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT U.NOMBRE, U.A_PATERNO
        FROM USUARIOS_EVENTOS UE
        JOIN USUARIOS U ON UE.USUARIO = U.ID_USUARIO
        WHERE UE.EVENTO = %s AND U.ID_USUARIO != %s;
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (id_evento, user_id))
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        usuarios = []
        for result in results:
            usuario = dict(zip(columns, result))
            usuarios.append(usuario)
        
        return jsonify(usuarios), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
    
@eventos_bp.route('/registrarParticipacion', methods=['POST'])
def registrar_participacion():
    session_key = request.headers.get('key')
    
    data = request.json
    user_id = data.get('user_id')
    id_evento = data.get('id_evento')
    
    query = """
        INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO)
        VALUES (%s, %s);
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id, id_evento))
        cnx.commit()
        cursor.close()
        
        return jsonify({"message": "Participación registrada."}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
    
    

@eventos_bp.route('/crearEvento', methods=['POST'])
def crear_evento():
    return "Crear Evento"



@eventos_bp.route('/qr', methods=['GET'])
def qr():
    return "QR Endpoint"

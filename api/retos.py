from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key

retos_bp = Blueprint('retos', __name__)

@retos_bp.route('/getRetos', methods=['GET'])
def get_retos():
    session_key = request.headers.get('key')

    # Validar la clave de sesión
    if not session_key or validate_key(session_key) is None:
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    query = """
        SELECT ID_RETO, NOMBRE, DESCRIPCION, PUNTAJE, CONTACTO, FECHA_LIMITE 
        FROM RETOS;
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query)
        
        columns = [column[0] for column in cursor.description]
        results = cursor.fetchall()
        cursor.close()
        
        retos = []
        for result in results:
            reto = dict(zip(columns, result))
            retos.append(reto)
        
        return jsonify(retos), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@retos_bp.route('/getMyRetos/<int:user_id>', methods=['GET'])
def get_my_retos(user_id):
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
        SELECT R.ID_RETO, R.NOMBRE, R.DESCRIPCION, R.PUNTAJE, R.CONTACTO, R.FECHA_LIMITE 
        FROM RETOS R
        JOIN USUARIOS_RETOS UR ON R.ID_RETO = UR.ID_RETO
        WHERE UR.ID = %s;
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
        print(f"Fetched {len(results)} retos.")
        
        retos = []
        for result in results:
            reto = dict(zip(columns, result))
            retos.append(reto)
        
        return jsonify(retos), 200
    except Exception as e:
        # Depurar en caso de error
        print(f"An error occurred: {str(e)}")
        return jsonify({"error": str(e)}), 500
    

@retos_bp.route('/registerReto', methods=['POST'])
def register_reto():
    session_key = request.headers.get('key')
    
    # Validar la clave de sesión
    if not session_key:
        return jsonify({"error": "Llave de sesión faltante."}), 400

    valid_user_id = validate_key(session_key)
    
    # Verificar que la clave de sesión sea válida
    if valid_user_id is None:
        return jsonify({"error": "Llave de sesión inválida."}), 400

    data = request.json
    user_id = data.get('user_id')
    id_reto = data.get('id_reto')
    
    # Verificar que se envíen los datos necesarios
    if not user_id or not id_reto:
        return jsonify({"error": "Faltan datos necesarios (user_id o id_reto)."}), 400

    # Verificar que el user_id en el cuerpo coincida con el user_id de la sesión
    if valid_user_id != user_id:
        return jsonify({"error": "El ID de usuario no coincide con la sesión."}), 400
    
    query = """
        INSERT INTO USUARIOS_RETOS (ID, ID_RETO)
        VALUES (%s, %s);
    """
    
    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id, id_reto))
        cnx.commit()
        cursor.close()
        
        return jsonify({"message": "Usuario registrado al reto exitosamente."}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
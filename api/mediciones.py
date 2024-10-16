from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key
from logger import my_logger  # Import the logger

mediciones_bp = Blueprint('mediciones', __name__)

@mediciones_bp.route('/borrarMedicion', methods=['DELETE'])
def borrar_medicion():
    """
    Elimina una medición de la base de datos.
    Documentado por german
    ---
    tags:
      - Sprint 3
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            user_id:
              type: integer
              description: ID del usuario que solicita la eliminación.
              example: 123
            medicion_id:
              type: integer
              description: ID de la medición que se desea eliminar.
              example: 456
      - in: header
        name: key
        required: true
        type: string
        description: Clave de sesión del usuario.
        example: "abcd1234sessionkey"
    responses:
      200:
        description: Medición eliminada exitosamente.
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Medición deleted successfully"
      400:
        description: Error en la solicitud por clave de sesión inválida o falta de datos.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Invalid session key"
      404:
        description: La medición no se encontró o no pertenece al usuario.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Medición not found or belongs to another user"
      500:
        description: Error interno del servidor al intentar eliminar la medición.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Mensaje detallado del error"
    """
    user_id = request.json.get('user_id')
    medicion_id = request.json.get('medicion_id')
    session_key = request.headers.get('key')

    # Log the incoming request
    my_logger.info(f"Request to /borrarMedicion with user_id: {user_id}, medicion_id: {medicion_id}")

    if not session_key or validate_key(session_key) != user_id:
        my_logger.warning(f"Invalid session key for user_id: {user_id}")
        return jsonify({"error": "Invalid session key"}), 400

    if not medicion_id:
        my_logger.warning(f"Medicion ID is missing for user_id: {user_id}")
        return jsonify({"error": "Medición ID is required"}), 400

    delete_query = """
        DELETE FROM MEDICIONES
        WHERE ID = %s AND USUARIO = %s
    """

    try:
        cursor = cnx.cursor()
        cursor.execute(delete_query, (medicion_id, user_id))
        cnx.commit()

        if cursor.rowcount > 0:
            my_logger.info(f"Medición {medicion_id} deleted for user_id: {user_id}")
            return jsonify({"message": "Medición deleted successfully"}), 200
        else:
            my_logger.warning(f"Medición {medicion_id} not found or belongs to another user: {user_id}")
            return jsonify({"error": "Medición not found or belongs to another user"}), 404
    except Exception as e:
        my_logger.error(f"Error deleting medición {medicion_id} for user_id: {user_id} - {str(e)}")
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@mediciones_bp.route('/historialMediciones', methods=['GET'])
def historial_mediciones():
    """
    Obtiene el historial de mediciones de un usuario.
    Documentado por german
    ---
    tags:
      - Sprint 3
    parameters:
      - in: query
        name: user_id
        type: integer
        required: true
        description: ID del usuario para obtener el historial de mediciones.
        example: 123
      - in: header
        name: key
        type: string
        required: true
        description: Clave de sesión del usuario.
        example: "abcd1234sessionkey"
    responses:
      200:
        description: Historial de mediciones devuelto con éxito.
        schema:
          type: object
          properties:
            historial:
              type: array
              items:
                type: object
                properties:
                  fecha:
                    type: string
                    example: "2024-01-01"
                  tipo:
                    type: string
                    example: "Peso"
                  valor:
                    type: number
                    example: 70
      400:
        description: Clave de sesión inválida o falta de datos.
      404:
        description: No se encontraron mediciones para este usuario.
      500:
        description: Error interno del servidor.
    """
    user_id = request.args.get('user_id')
    session_key = request.headers.get('key')

    # Log the incoming request
    my_logger.info(f"Request to /historialMediciones for user_id: {user_id}")

    if not session_key or validate_key(session_key) != user_id:
        my_logger.warning(f"Invalid session key for user_id: {user_id}")
        return jsonify({"error": "Invalid session key"}), 400

    query = """
        SELECT FECHA, TIPO, VALOR
        FROM MEDICIONES
        WHERE USUARIO = %s
        ORDER BY FECHA DESC
    """

    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        mediciones_result = cursor.fetchall()

        if mediciones_result:
            mediciones_data = [
                {"fecha": row[0], "tipo": row[1], "valor": row[2]}
                for row in mediciones_result
            ]
            my_logger.info(f"Successfully fetched measurements for user_id: {user_id}")
            return jsonify({"historial": mediciones_data}), 200
        else:
            my_logger.info(f"No health measurements found for user_id: {user_id}")
            return jsonify({"message": "No health measurements found for this user"}), 404

    except Exception as e:
        my_logger.error(f"Error fetching measurements for user_id: {user_id} - {str(e)}")
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@mediciones_bp.route('/datossalud/<int:user_id>', methods=['GET'])
def datos_salud(user_id):
    """
    Obtiene los datos de salud del usuario.
    Documentado por German
    ---
    tags:
      - Sprint 3
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario para obtener sus datos de salud.
        example: 123
      - in: header
        name: key
        type: string
        required: true
        description: Clave de sesión del usuario.
        example: "abcd1234sessionkey"
    responses:
      200:
        description: Datos de salud devueltos con éxito.
        schema:
          type: object
          properties:
            resultados:
              type: object
              properties:
                edad:
                  type: integer
                  example: 30
                tipo_sangre:
                  type: string
                  example: "O+"
                genero:
                  type: string
                  example: "M"
                peso:
                  type: number
                  example: 70
                altura:
                  type: number
                  example: 1.75
      400:
        description: Clave de sesión inválida.
      404:
        description: No se encontraron datos de salud para este usuario.
      500:
        description: Error interno del servidor.
    """
    my_logger.info(f"Request to /datossalud for user_id: {user_id}")

    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        return jsonify({"error": "Invalid session key"}), 400

    query = """
        SELECT DS.EDAD, DS.TIPO_SANGRE, DS.GENERO, DS.PESO, DS.ALTURA
        FROM DATOS_SALUD DS
        WHERE USUARIO = %s
    """

    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))

        result = cursor.fetchone()
        cursor.close()

        if result:
            formatted_result = {
                "edad": result[0],
                "tipo_sangre": result[1],
                "genero": result[2],
                "peso": result[3],
                "altura": result[4]
            }
            return jsonify({"resultados": formatted_result}), 200
        else:
            return jsonify({"No health data from this user"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@mediciones_bp.route('/medicionesdatos/<int:user_id>', methods=['GET'])
def obtener_mediciones(user_id):
    """
    Obtiene las mediciones de glucosa, ritmo cardíaco, presión arterial y la información de salud de un usuario.
    Documentado por Fer.
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
      - in: path
        name: user_id
        type: integer
        required: true
        description: ID del usuario para obtener sus mediciones.
        example: 123
    responses:
      200:
        description: Mediciones del usuario devueltas exitosamente.
        schema:
          type: object
          properties:
            resultados:
              type: object
              properties:
                glucosa:
                  type: array
                  items:
                    type: object
                    properties:
                      fecha:
                        type: string
                        example: "2024-10-14"
                      glucosa:
                        type: integer
                        example: 110
                ritmo_cardiaco:
                  type: array
                  items:
                    type: object
                    properties:
                      fecha:
                        type: string
                        example: "2024-10-14"
                      ritmo:
                        type: integer
                        example: 75
                presion_arterial:
                  type: array
                  items:
                    type: object
                    properties:
                      fecha:
                        type: string
                        example: "2024-10-14"
                      presion_sistolica:
                        type: integer
                        example: 120
                      presion_diastolica:
                        type: integer
                        example: 80
                usuario_info:
                  type: object
                  properties:
                    nombre:
                      type: string
                      example: "Juan"
                    a_paterno:
                      type: string
                      example: "Pérez"
                    a_materno:
                      type: string
                      example: "Gómez"
                    edad:
                      type: integer
                      example: 30
                    tipo_sangre:
                      type: string
                      example: "O+"
                    genero:
                      type: string
                      example: "Masculino"
                    peso:
                      type: number
                      example: 70.5
                    altura:
                      type: number
                      example: 1.75
      400:
        description: Llave de sesión inválida.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Llave de sesión inválida."
      404:
        description: No se encontraron resultados para este usuario.
        schema:
          type: object
          properties:
            message:
              type: string
              example: "No se encontraron resultados para este usuario."
      500:
        description: Error interno del servidor.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Error al procesar la solicitud."
    """
    session_key = request.headers.get('key')

    # Logging para la solicitud
    my_logger.info(f"({request.remote_addr}) Requested /medicionesdatos for user_id {user_id}")

    # Validar clave de sesión
    if not session_key or validate_key(session_key) != user_id:
        my_logger.warning(f"({request.remote_addr}) Invalid session key for user_id {user_id}")
        return jsonify({"error": "Llave de sesión inválida."}), 400
    
    glucosa_query = """
        SELECT TOP 5 G.FECHA, G.NIVEL
        FROM GLUCOSA G
        WHERE G.USUARIO = %s
        ORDER BY G.FECHA DESC
    """

    ritmo_cardiaco_query = """
        SELECT TOP 5 RC.FECHA, RC.RITMO
        FROM RITMO_CARDIACO RC
        WHERE RC.USUARIO = %s
        ORDER BY RC.FECHA DESC
    """

    presion_arterial_query = """
        SELECT TOP 5 PA.FECHA, PA.PRESION_SISTOLICA, PA.PRESION_DIASTOLICA
        FROM PRESION_ARTERIAL PA
        WHERE PA.USUARIO = %s
        ORDER BY PA.FECHA DESC
    """

    userInfo_query = """
        SELECT 
            U.NOMBRE, 
            U.A_PATERNO,
            U.A_MATERNO,
            DS.EDAD, 
            DS.TIPO_SANGRE, 
            DS.GENERO, 
            DS.PESO, 
            DS.ALTURA
        FROM 
            USUARIOS U
        JOIN 
            DATOS_SALUD DS 
        ON 
            U.ID_USUARIO = DS.USUARIO
        WHERE 
            U.ID_USUARIO =  %s;
    """

    try:
        cursor = cnx.cursor()

        cursor.execute(glucosa_query, (user_id,))
        glucosa_result = cursor.fetchall()

        cursor.execute(ritmo_cardiaco_query, (user_id,))
        ritmo_cardiaco_result = cursor.fetchall()

        cursor.execute(presion_arterial_query, (user_id,))
        presion_arterial_result = cursor.fetchall()

        cursor.execute(userInfo_query, (user_id,))
        userInfo_result = cursor.fetchone()

        cursor.close()

        if glucosa_result and ritmo_cardiaco_result and presion_arterial_result and userInfo_result:
            glucosa_data = [
                {"fecha": row[0], "glucosa": row[1]}
                for row in glucosa_result
            ]

            ritmo_cardiaco_data = [
                {"fecha": row[0], "ritmo": row[1]}
                for row in ritmo_cardiaco_result
            ]

            presion_arterial_data = [
                {"fecha": row[0], "presion_sistolica": row[1], "presion_diastolica": row[2]}
                for row in presion_arterial_result
            ]

            userInfo_data = {
                "nombre": userInfo_result[0],
                "a_paterno": userInfo_result[1],
                "a_materno": userInfo_result[2],
                "edad": userInfo_result[3],
                "tipo_sangre": userInfo_result[4],
                "genero": userInfo_result[5],
                "peso": userInfo_result[6],
                "altura": userInfo_result[7]
            }

            return jsonify({"resultados": {
                "glucosa": glucosa_data,
                "ritmo_cardiaco": ritmo_cardiaco_data,
                "presion_arterial": presion_arterial_data,
                "usuario_info": userInfo_data
            }}), 200
        else:
            return jsonify({"No results from this user"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500

from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key
from logger import my_logger  # Import the logger

mediciones_bp = Blueprint('mediciones', __name__)

@mediciones_bp.route('/borrarMedicion', methods=['DELETE'])
def borrar_medicion():
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
    session_key = request.headers.get('key')

    my_logger.info(f"Request to /medicionesdatos for user_id: {user_id}")

    if not session_key or validate_key(session_key) != user_id:
        return jsonify({"error": "Invalid session key"}), 400
    
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

    try:
        cursor = cnx.cursor()

        cursor.execute(glucosa_query, (user_id,))
        glucosa_result = cursor.fetchall()

        cursor.execute(ritmo_cardiaco_query, (user_id,))
        ritmo_cardiaco_result = cursor.fetchall()

        cursor.execute(presion_arterial_query, (user_id,))
        presion_arterial_result = cursor.fetchall()

        cursor.close()

        if glucosa_result and ritmo_cardiaco_result and presion_arterial_result:
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

            return jsonify({"resultados": {
                "glucosa": glucosa_data,
                "ritmo_cardiaco": ritmo_cardiaco_data,
                "presion_arterial": presion_arterial_data
            }}), 200
        else:
            return jsonify({"No results from this user"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500

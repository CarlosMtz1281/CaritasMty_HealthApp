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
from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key

from logger import my_logger  


mediciones_bp = Blueprint('mediciones', __name__)

@mediciones_bp.route('/borrarMedicion', methods=['DELETE'])
def borrar_medicion():
    user_id = request.json.get('user_id')
    medicion_id = request.json.get('medicion_id')
    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
        return jsonify({"error": "Invalid session key"}), 400

    if not medicion_id:
        return jsonify({"error": "Medición ID is required"}), 400

    delete_query = """
        DELETE FROM MEDICIONES
        WHERE ID = %s AND USUARIO = %s
    """

    try:
        cursor = cnx.cursor()
        cursor.execute(delete_query, (medicion_id, user_id))
        cnx.commit()
        cursor.close()

        if cursor.rowcount > 0:
            return jsonify({"message": "Medición deleted successfully"}), 200
        else:
            return jsonify({"error": "Medición not found or belongs to another user"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@mediciones_bp.route('/historialMediciones', methods=['GET'])
def historial_mediciones():
    user_id = request.args.get('user_id')
    session_key = request.headers.get('key')

    if not session_key or validate_key(session_key) != user_id:
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
        cursor.close()

        if mediciones_result:
            mediciones_data = [
                {"fecha": row[0], "tipo": row[1], "valor": row[2]}
                for row in mediciones_result
            ]
            return jsonify({"historial": mediciones_data}), 200
        else:
            return jsonify({"message": "No health measurements found for this user"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500
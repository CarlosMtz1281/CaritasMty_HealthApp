from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import create_session, validate_key, delete_session

mediciones_bp = Blueprint('mediciones', __name__)

@mediciones_bp.route('/borrarMedicion', methods=['DELETE'])
def borrar_medicion():
    return "Borrar Medición"

@mediciones_bp.route('/historialMediciones', methods=['GET'])
def historial_mediciones():
    return "Historial Mediciones"

@mediciones_bp.route('/datossalud/<int:user_id>', methods=['GET'])
def datos_salud(user_id):
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
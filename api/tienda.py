from flask import Blueprint, jsonify, request
from database import cnx
import logging
from session_manager import  validate_key


logging.basicConfig(level=logging.DEBUG)


tienda_bp = Blueprint('tienda', __name__)

@tienda_bp.route('/catalogo', methods=['GET'])
def catalogo():
    key = request.headers.get('key')

    if not key or not validate_key(key):
        return jsonify({"error": "Invalid session key"}), 400

    query = """
    SELECT * from BENEFICIOS
    """
    try:
        # Ensure the connection is established
        if cnx is None:
            logging.error("Database connection is not established.")
            return jsonify({"error": "Database connection is not established."}), 500

        cursor = cnx.cursor()
        cursor.execute(query)

        # Check if the cursor has any results
        if cursor.description is None:
            logging.error("Query did not return any results.")
            return jsonify({"error": "Query did not return any results."}), 500

        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()

        # Log the results for debugging
        logging.debug(f"Query results: {results}")

        return jsonify(results), 200
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")
        return jsonify({"error": str(e)}), 500

@tienda_bp.route('/comprarBono', methods=['POST'])
def comprar_bono():
    return "Comprar Bono"

@tienda_bp.route('/bonosComprados', methods=['GET'])
def bonos_comprados():
    return "Bonos Comprados"

@tienda_bp.route('/crearBono', methods=['POST'])
def crear_bono():
    return "Crear Bono"

@tienda_bp.route('/borrarBono', methods=['DELETE'])
def borrar_bono():
    return "Borrar Bono"

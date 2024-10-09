from flask import Blueprint, jsonify, request
from database import cnx
import logging
from session_manager import validate_key

from logger import my_logger  


# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Create a Blueprint for 'Tienda'
tienda_bp = Blueprint('tienda', __name__)

# Route to get the catalog of benefits
@tienda_bp.route('/catalogo', methods=['GET'])
def catalogo():
    """
    Obtiene el catálogo de beneficios disponibles para canjear.
    Documentado por Carlos.
    """
    logging.debug("Starting /catalogo request.")

    key = request.headers.get('key')
    if not key or not validate_key(key):
        logging.warning("Invalid or missing session key.")
        return jsonify({"error": "Llave de sesión inválida."}), 400

    query = "SELECT * FROM BENEFICIOS"
    
    try:
        if cnx is None:
            logging.error("Database connection not established.")
            return jsonify({"error": "No se estableció la conexión con la Base de Datos."}), 500

        cursor = cnx.cursor()
        cursor.execute(query)
        
        # Check if query returned any results
        if cursor.description is None:
            logging.error("Query did not return any results.")
            return jsonify({"error": "No se obtuvieron resultados de la Query."}), 500

        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()

        logging.debug("Catalog query executed successfully.")
        return jsonify(results), 200

    except Exception as e:
        logging.error(f"Error occurred during /catalogo: {str(e)}")
        return jsonify({"error": str(e)}), 500


# Route to handle the purchase of a benefit
@tienda_bp.route('/comprarBono', methods=['POST'])
def comprar_bono():
    """
    Maneja la compra de un beneficio por parte de un usuario.
    """
    logging.debug("Starting /comprarBono request.")

    session_key = request.headers.get('key')
    data = request.json
    user_id = data.get('user_id')
    puntos = data.get('puntos')
    beneficio_id = data.get('beneficio_id')

    if not session_key or validate_key(session_key) != user_id:
        logging.warning("Invalid session key.")
        return jsonify({"error": "Llave de sesión inválida."}), 400

    query_checarBeneficio = """
    SELECT CASE WHEN EXISTS (
        SELECT 1
        FROM USUARIOS_BENEFICIOS
        WHERE USUARIO = %s AND BENEFICIO = %s
    ) THEN 'True' ELSE 'False' END AS TIENE_BENEFICIO;
    """

    query_puntajeBeneficio = "SELECT PUNTOS FROM BENEFICIOS WHERE ID_BENEFICIO = %s"
    query_restaPuntos = "UPDATE PUNTOS_USUARIO SET PUNTOS_ACTUALES = %s WHERE USUARIO = %s"
    query_historialBeneficios = "INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO) VALUES(%s ,%s)"
    query_historialPuntos = """
    INSERT INTO HISTORIAL_PUNTOS (USUARIO, FECHA, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, BENEFICIO, EVENTO, RETO)
    VALUES (%s, GETDATE(), %s, 0, %s, NULL, NULL);
    """

    try:
        cursor = cnx.cursor()
        
        # Check if the user has already bought the benefit
        cursor.execute(query_checarBeneficio, (user_id, beneficio_id))
        row = cursor.fetchone()
        tiene_beneficio = row[0] == 'True'
        
        if tiene_beneficio:
            logging.warning(f"User {user_id} already purchased benefit {beneficio_id}.")
            return jsonify({"conflict": "Beneficio ya comprado anteriormente. Seleccione un beneficio distinto"}), 409

        cursor.execute(query_puntajeBeneficio, (beneficio_id,))
        row = cursor.fetchone()
        costo_beneficio = row[0]

        if puntos >= costo_beneficio:
            puntosAct = puntos - costo_beneficio
            cursor.execute(query_restaPuntos, (puntosAct, user_id))
            logging.debug(f"Points deducted for user {user_id}: {puntosAct} remaining.")

            # Add to benefit history
            cursor.execute(query_historialBeneficios, (user_id, beneficio_id))
            logging.debug(f"Benefit {beneficio_id} added to history for user {user_id}.")

            # Add to points history
            cursor.execute(query_historialPuntos, (user_id, costo_beneficio, beneficio_id))
            logging.debug(f"Points history updated for user {user_id}.")

            cnx.commit()
            return jsonify({"message": "Beneficio comprado exitosamente"}), 200
        else:
            logging.warning(f"User {user_id} has insufficient points. Required: {costo_beneficio}, Available: {puntos}.")
            return jsonify({"conflict": "Puntos insuficientes"}), 409

    except Exception as e:
        logging.error(f"Error occurred during /comprarBono: {str(e)}")
        cnx.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()


# Additional route stubs (to be implemented) with logging
@tienda_bp.route('/bonosComprados', methods=['GET'])
def bonos_comprados():
    logging.debug("Starting /bonosComprados request.")
    return "Bonos Comprados"

@tienda_bp.route('/crearBono', methods=['POST'])
def crear_bono():
    logging.debug("Starting /crearBono request.")
    return "Crear Bono"

@tienda_bp.route('/borrarBono', methods=['DELETE'])
def borrar_bono():
    logging.debug("Starting /borrarBono request.")
    return "Borrar Bono"
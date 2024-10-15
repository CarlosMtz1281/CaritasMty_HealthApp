from flask import Blueprint, jsonify, request
from database import cnx
from session_manager import validate_key

from logger import my_logger  


# Create a Blueprint for 'Tienda'
tienda_bp = Blueprint('tienda', __name__)

# Route to get the catalog of benefits
@tienda_bp.route('/catalogo', methods=['GET'])
def catalogo():
    """
    Obtiene el catálogo de beneficios disponibles para canjear.
    Documentado por Carlos.
    ---
    tags:
      - Sprint 2
    parameters:
      - in: header
        name: key
        type: string
        required: true
        description: Clave de sesión del usuario.
        example: "abcd1234sessionkey"
    responses:
      200:
        description: Catálogo de beneficios devuelto exitosamente.
        schema:
          type: array
          items:
            type: object
            properties:
              ID_BENEFICIO:
                type: integer
                example: 1
              NOMBRE:
                type: string
                example: "Descuento en productos"
              DESCRIPCION:
                type: string
                example: "20% de descuento en productos seleccionados"
              PUNTOS:
                type: integer
                example: 100
              FECHA_EXPIRACION:
                type: string
                example: "2024-12-31"
      400:
        description: Llave de sesión inválida o faltante.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Llave de sesión inválida."
      500:
        description: Error interno del servidor.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "No se estableció la conexión con la Base de Datos."
    """
    my_logger.debug("Starting /catalogo request.")

    key = request.headers.get('key')
    if not key or not validate_key(key):
        my_logger.warning("Invalid or missing session key.")
        return jsonify({"error": "Llave de sesión inválida."}), 400

    query = "SELECT * FROM BENEFICIOS"
    
    try:
        if cnx is None:
            my_logger.error("Database connection not established.")
            return jsonify({"error": "No se estableció la conexión con la Base de Datos."}), 500

        cursor = cnx.cursor()
        cursor.execute(query)
        
        # Check if query returned any results
        if cursor.description is None:
            my_logger.error("Query did not return any results.")
            return jsonify({"error": "No se obtuvieron resultados de la Query."}), 500

        columns = [column[0] for column in cursor.description]
        results = [dict(zip(columns, row)) for row in cursor.fetchall()]
        cursor.close()

        my_logger.debug("Catalog query executed successfully.")
        return jsonify(results), 200

    except Exception as e:
        my_logger.error(f"Error occurred during /catalogo: {str(e)}")
        return jsonify({"error": str(e)}), 500


# Route to handle the purchase of a benefit
@tienda_bp.route('/comprarBono', methods=['POST'])
def comprar_bono():
    """
    Maneja la compra de un beneficio por parte de un usuario.
    Documentado por Carlos.
    ---
    tags:
      - Sprint 2
    parameters:
      - in: header
        name: key
        type: string
        required: true
        description: Clave de sesión del usuario.
        example: "abcd1234sessionkey"
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            user_id:
              type: integer
              description: ID del usuario que está realizando la compra.
              example: 123
            puntos:
              type: integer
              description: Puntos actuales del usuario.
              example: 200
            beneficio_id:
              type: integer
              description: ID del beneficio a comprar.
              example: 456
    responses:
      200:
        description: Beneficio comprado exitosamente.
        schema:
          type: object
          properties:
            message:
              type: string
              example: "Beneficio comprado exitosamente."
      400:
        description: Llave de sesión inválida o datos faltantes.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Llave de sesión inválida."
      409:
        description: El beneficio ya fue comprado previamente o puntos insuficientes.
        schema:
          type: object
          properties:
            conflict:
              type: string
              example: "Beneficio ya comprado anteriormente."
      500:
        description: Error interno del servidor.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Error al procesar la solicitud."
    """
    
    my_logger.debug("Starting /comprarBono request.")

    session_key = request.headers.get('key')
    data = request.json
    user_id = data.get('user_id')
    puntos = data.get('puntos')
    beneficio_id = data.get('beneficio_id')

    if not session_key or validate_key(session_key) != user_id:
        my_logger.warning("Invalid session key.")
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
            my_logger.warning(f"User {user_id} already purchased benefit {beneficio_id}.")
            return jsonify({"conflict": "Beneficio ya comprado anteriormente. Seleccione un beneficio distinto"}), 409

        cursor.execute(query_puntajeBeneficio, (beneficio_id,))
        row = cursor.fetchone()
        costo_beneficio = row[0]

        if puntos >= costo_beneficio:
            puntosAct = puntos - costo_beneficio
            cursor.execute(query_restaPuntos, (puntosAct, user_id))
            my_logger.debug(f"Points deducted for user {user_id}: {puntosAct} remaining.")

            # Add to benefit history
            cursor.execute(query_historialBeneficios, (user_id, beneficio_id))
            my_logger.debug(f"Benefit {beneficio_id} added to history for user {user_id}.")

            # Add to points history
            cursor.execute(query_historialPuntos, (user_id, costo_beneficio, beneficio_id))
            my_logger.debug(f"Points history updated for user {user_id}.")

            cnx.commit()
            return jsonify({"message": "Beneficio comprado exitosamente"}), 200
        else:
            my_logger.warning(f"User {user_id} has insufficient points. Required: {costo_beneficio}, Available: {puntos}.")
            return jsonify({"conflict": "Puntos insuficientes"}), 409

    except Exception as e:
        my_logger.error(f"Error occurred during /comprarBono: {str(e)}")
        cnx.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

# Ruta para mostrar los bonos comprados por un usuario
@tienda_bp.route('/bonosComprados/<int:user_id>', methods=['GET'])
def bonos_comprados(user_id):
    """
    Muestra los bonos comprados por el usuario.
    Documentado por Nico.
    ---
    tags:
      - Sprint 2
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
        description: ID del usuario para obtener sus bonos comprados.
        example: 123
    responses:
      200:
        description: Bonos comprados devueltos exitosamente.
        schema:
          type: array
          items:
            type: object
            properties:
              ID_BENEFICIO:
                type: integer
                example: 1
              NOMBRE:
                type: string
                example: "Descuento en productos"
              DESCRIPCION:
                type: string
                example: "20% de descuento en productos seleccionados"
              PUNTOS:
                type: integer
                example: 100
      400:
        description: Llave de sesión inválida o faltante.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Llave de sesión inválida."
      404:
        description: No se encontraron bonos comprados para este usuario.
        schema:
          type: object
          properties:
            message:
              type: string
              example: "No se encontraron bonos comprados para este usuario."
      500:
        description: Error interno del servidor.
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Error al procesar la solicitud."
    """

    my_logger.debug("Starting /bonosComprados request.")

    # Obtener la clave de sesión desde los headers
    session_key = request.headers.get('key')

    # Validar la clave de sesión y el user_id
    if not session_key or validate_key(session_key) != int(user_id):
        my_logger.warning("Invalid or missing session key.")
        return jsonify({"error": "Llave de sesión inválida."}), 400

    # Consulta SQL para obtener los beneficios comprados por el usuario
    query = """
        SELECT B.ID_BENEFICIO, B.NOMBRE, B.DESCRIPCION, B.PUNTOS
        FROM BENEFICIOS B
        JOIN USUARIOS_BENEFICIOS UB ON B.ID_BENEFICIO = UB.BENEFICIO
        WHERE UB.USUARIO = %s;
    """

    try:
        cursor = cnx.cursor()
        cursor.execute(query, (user_id,))
        bonos_result = cursor.fetchall()

        if bonos_result:
            # Convertir los resultados en un diccionario para la respuesta
            bonos = [
                {"ID_BENEFICIO": row[0], "NOMBRE": row[1], "DESCRIPCION": row[2], "PUNTOS": row[3]}
                for row in bonos_result
            ]
            my_logger.debug(f"Fetched {len(bonos)} bonos comprados for user_id {user_id}.")
            return jsonify(bonos), 200
        else:
            my_logger.info(f"No purchased bonos found for user_id {user_id}.")
            return jsonify({"message": "No se encontraron bonos comprados para este usuario."}), 404

    except Exception as e:
        my_logger.error(f"Error occurred during /bonosComprados: {str(e)}")
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()


@tienda_bp.route('/crearBono', methods=['POST'])
def crear_bono():
    my_logger.debug("Starting /crearBono request.")
    return "Crear Bono"

@tienda_bp.route('/borrarBono', methods=['DELETE'])
def borrar_bono():
    my_logger.debug("Starting /borrarBono request.")
    return "Borrar Bono"
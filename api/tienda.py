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
def comprar_bono(): #pendiente checar que pedo con la validacion con el hash de nico, yo no creo que se necesite 
    data = request.json
    user_id = data.get('user_id')
    puntos = data.get('puntos')
    beneficio_id = data.get('beneficio_id') #id_beneficio

    query_checarBeneficio = """
    SELECT CASE WHEN EXISTS (
        SELECT 1
        FROM USUARIOS_BENEFICIOS
        WHERE USUARIO = %s AND BENEFICIO = %s
    ) THEN 'True' ELSE 'False' END AS TIENE_BENEFICIO;
    """

    query_puntajeBeneficio = """
    SELECT PUNTOS
    FROM BENEFICIOS
    WHERE ID_BENEFICIO = %s
    """

    query_restaPuntos = """
    UPDATE PUNTOS_USUARIO
    SET PUNTOS_ACTUALES = %s
    WHERE USUARIO = %s
    """

    query_historialBeneficios = """
    INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO)
    VALUES(%s ,%s)
    """

    query_historialPuntos = """
    INSERT INTO HISTORIAL_PUNTOS (USUARIO, FECHA, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, BENEFICIO, EVENTO, RETO)
    VALUES (%s, GETDATE(), %s, 0, %s, NULL, NULL);
    """

    try:
        cursor = cnx.cursor()
        # verificar que el usuario no cuente ya con ese beneficio
        cursor.execute(query_checarBeneficio, (user_id, beneficio_id))
        row = cursor.fetchone()
        tiene_beneficio = row[0] == 'True'
        if tiene_beneficio:
            #no puede volver a comprarlo
            return jsonify({"conflict": "Beneficio ya comprado anteriormente. Seleccione un beneficio distinto"}), 409
        else:
            cursor.execute(query_puntajeBeneficio, (beneficio_id))
            row = cursor.fetchone()
            costo_beneficio = row[0]
            print(f"Se obtuvo el precio del beneficio {costo_beneficio}")
            

            if puntos >= costo_beneficio:
                #comprar el beneficio (restar puntos)
                puntosAct = puntos - costo_beneficio
                cursor.execute(query_restaPuntos, (puntosAct, user_id))
                print(f"Puntos actuales {puntos} - costo beneficio {costo_beneficio} = {puntosAct}")

                #agregar al historial en usuarios_beneficios
                cursor.execute(query_historialBeneficios, (user_id, beneficio_id))
                print("Se agregó al historial de beneficios")

                #agregar al historial puntos
                cursor.execute(query_historialPuntos, (user_id, costo_beneficio, beneficio_id))
                print("Se agregó al historial de puntos")

                cnx.commit()
                return jsonify({"message": "Beneficio comprado exitosamente"}), 200
            else:
                print(f"Puntos del usuario: {puntos}, Costo del beneficio: {costo_beneficio}")
                return jsonify({"conflict": "Puntos insuficientes"}), 409
    except Exception as e:
            cnx.rollback()
            return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()


@tienda_bp.route('/bonosComprados', methods=['GET'])
def bonos_comprados():
    return "Bonos Comprados"

@tienda_bp.route('/crearBono', methods=['POST'])
def crear_bono():
    return "Crear Bono"

@tienda_bp.route('/borrarBono', methods=['DELETE'])
def borrar_bono():
    return "Borrar Bono"

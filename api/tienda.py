from flask import Blueprint

tienda_bp = Blueprint('tienda', __name__)

@tienda_bp.route('/catalogo', methods=['GET'])
def catalogo():
    return "Catálogo"

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

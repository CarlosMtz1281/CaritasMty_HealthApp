from flask import Blueprint

mediciones_bp = Blueprint('mediciones', __name__)

@mediciones_bp.route('/borrarMedicion', methods=['DELETE'])
def borrar_medicion():
    return "Borrar Medición"

@mediciones_bp.route('/historialMediciones', methods=['GET'])
def historial_mediciones():
    return "Historial Mediciones"

from flask import Blueprint

eventos_bp = Blueprint('eventos', __name__)

@eventos_bp.route('/historialUsuario', methods=['GET'])
def historial_usuario():
    return "Historial Usuario"

@eventos_bp.route('/crearEvento', methods=['POST'])
def crear_evento():
    return "Crear Evento"

@eventos_bp.route('/registrarParticipacion', methods=['POST'])
def registrar_participacion():
    return "Registrar Participación"

@eventos_bp.route('/qr', methods=['GET'])
def qr():
    return "QR Endpoint"

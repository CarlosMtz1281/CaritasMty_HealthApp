import uuid

session_storage = {}

# crear el key para usuarios con el id
def create_session(user_id):
    session_key = str(uuid.uuid4())
    session_storage[session_key] = {
        'user_id': user_id
    }
    return session_key

# checar si existe y regresar el id del usuario
def validate_key(session_key):
    if session_key in session_storage:
        return session_storage[session_key]['user_id']
    return None

# eliminar en el signout
def delete_session(session_key):
    if session_key in session_storage:
        del session_storage[session_key]

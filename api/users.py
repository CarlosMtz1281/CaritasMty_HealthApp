from flask import Blueprint

users_bp = Blueprint('users', __name__)

@users_bp.route('/login', methods=['POST'])
def login():
    return "User login"

@users_bp.route('/genKey', methods=['POST'])
def gen_key():
    return "Generate Key"

@users_bp.route('/signOut', methods=['POST'])
def sign_out():
    return "Sign Out"

@users_bp.route('/signUp', methods=['POST'])
def sign_up():
    return "Sign Up"

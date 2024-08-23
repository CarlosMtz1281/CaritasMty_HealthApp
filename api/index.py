from flask import Flask
from users import users_bp
from eventos import eventos_bp
from mediciones import mediciones_bp
from tienda import tienda_bp

app = Flask(__name__)

app.register_blueprint(users_bp, url_prefix='/users')
app.register_blueprint(eventos_bp, url_prefix='/eventos')
app.register_blueprint(mediciones_bp, url_prefix='/mediciones')
app.register_blueprint(tienda_bp, url_prefix='/tienda')

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

if __name__ == "__main__":
    app.run(host='localhost', port=8000)

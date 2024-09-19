import pyodbc
import sys

vm_params = {
    'DB_HOST': '100.80.80.7',
    'DB_NAME': 'alumno02',
    'DB_USER': 'SA',
    'DB_PASSWORD': 'Shakira123.'
}

local_params = {
    'DB_HOST': 'localhost',
    'DB_NAME': 'master',
    'DB_USER': 'sa',
    'DB_PASSWORD': '5abr1t0n3s_GOAT'
}

nico_local_params = {
    'DB_HOST': 'localhost\\SQLEXPRESS',
    'DB_NAME': 'master',
    'DB_USER': 'sa',
    'DB_PASSWORD': '5abr1t0n3s_GOAT'
}

def connect_to_db(params):
    """Conecta a la base de datos utilizando pyodbc y devuelve la conexión."""
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={params['DB_HOST']};"
        f"DATABASE={params['DB_NAME']};"
        f"UID={params['DB_USER']};"
        f"PWD={params['DB_PASSWORD']}"
    )
    try:
        return pyodbc.connect(conn_str)
    except pyodbc.Error as e:
        print(f"Cannot connect to MSSQL server: {e}")
        sys.exit()

cnx = connect_to_db(nico_local_params)
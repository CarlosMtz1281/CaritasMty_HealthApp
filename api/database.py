import pyodbc
import pymssql
import sys

localToVM_params = {
    'DB_HOST': '10.14.255.64',
    'DB_NAME': 'dummy', # usar tabla dummy
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

def connect_fer(params):
    conn = pymssql.connect(
        server=params['DB_HOST'],
        user=params['DB_USER'],
        password=params['DB_PASSWORD'],
        database='dummy'
    )
    return conn

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

#cnx = connect_to_db(local_params)

cnx =  connect_fer(localToVM_params)


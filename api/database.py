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

fer_local_params = {
    'DB_HOST': 'localhost',
    'DB_NAME': 'dummy',
    'DB_USER': 'sa',
    'DB_PASSWORD': '5abr1t0n3s_GOAT'
}

Ivan_local_params = {
    'DB_HOST': 'localhost',
    'DB_NAME': 'master',
    'DB_USER': 'IVAN',
    'DB_PASSWORD': '5abr1t0n3s_GOAT'
}

nico_local_params = {
    'DB_HOST': 'localhost\\SQLEXPRESS',
    'DB_NAME': 'master',
    'DB_USER': 'sa',
    'DB_PASSWORD': '5abr1t0n3s_GOAT'
}

def connect_db(params):
    conn = pymssql.connect(
        server=params['DB_HOST'],
        user=params['DB_USER'],
        password=params['DB_PASSWORD'],
        database=params['DB_NAME']
    )
    return conn

cnx =  connect_db(local_params)

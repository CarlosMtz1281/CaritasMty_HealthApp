import pymssql
import os
from dotenv import load_dotenv
load_dotenv()

local_params = {
    'DB_HOST': os.getenv('DB_HOST'),
    'DB_NAME': os.getenv('DB_NAME'),
    'DB_USER': os.getenv('DB_USER'),
    'DB_PASSWORD': os.getenv('DB_PASSWORD')
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
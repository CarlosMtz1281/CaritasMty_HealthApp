import mssql_functions as MSSql
import sys

vm_params = {}
vm_params['DB_HOST'] = '100.80.80.7'
vm_params['DB_NAME'] = 'alumno02'
vm_params['DB_USER'] = 'SA'
vm_params['DB_PASSWORD'] = 'Shakira123.'

local_params = {}
local_params['DB_HOST'] = "localhost:1433"
local_params['DB_NAME'] = "master"
local_params['DB_USER'] = "sa"
local_params['DB_PASSWORD'] = "5abr1t0n3s_GOAT"
cnx = None

try:
    MSSql.cnx = MSSql.mssql_connect(local_params)
    cnx = MSSql.cnx;
except Exception as e:
    print("Cannot connect to mssql server!: {}".format(e))
    sys.exit()
import pyodbc

def check_mssql_connection(server, database, username, password):
    try:
        # Create a connection string
        connection_string = f"DRIVER={{ODBC Driver 17 for SQL Server}};" \
                            f"SERVER={server};" \
                            f"DATABASE={database};" \
                            f"UID={username};" \
                            f"PWD={password}"

        # Establish a connection to the database
        conn = pyodbc.connect(connection_string)
        
        # Check if the connection is successful
        print("Connection successful!")
        
        # Close the connection
        conn.close()

    except pyodbc.Error as e:
        print("Error while connecting to SQL Server:", e)

# Parameters
server = 'localhost\\SQLEXPRESS'  # or your server name
database = 'master'
username = 'sa'
password = '5abr1t0n3s_GOAT'

# Call the function to check the connection
check_mssql_connection(server, database, username, password)

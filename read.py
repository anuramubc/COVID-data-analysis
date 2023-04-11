from util import get_mysql_connection as getconn


def read_table(db_details,table_name, limit=0):
    SOURCE_DB = db_details['SOURCE_DB']
    connection = getconn(db_host = SOURCE_DB['DB_HOST'], db_name= SOURCE_DB['DB_NAME'],
                                       db_user = SOURCE_DB['DB_USER'], db_pass =SOURCE_DB['DB_PASS'])
    
    cursor = connection.cursor()
    if limit == 0:
        query = f'SELECT * FROM {table_name}'
    else:
        query = f'SELECT * FROM {table_name} LIMIT {limit}'

    cursor.execute(query)
    data = cursor.fetchall()
    column_names = cursor.column_names
    connection.close()

    return data,column_names
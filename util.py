#read the contents of the table list
import pandas as pd
from config import DB_DETAILS
from mysql import connector as mc
from mysql.connector import errorcode as ec


#load db details
def load_db_details(dev):
    return DB_DETAILS[dev]

# load connection 
def get_mysql_connection(db_host, db_name, db_user, db_pass):
    try:
        connection = mc.connect(user = db_user, password = db_pass, host = db_host, database = db_name)
    except mc.Error as error:
        if error.errno == ec.ER_ACCESS_DENIED_ERROR:
            print("incorrect credentials")
        else:
            print(error)
    return connection


#get contents of the table specified in path from app.py
def get_tables(path):
    tables = pd.read_csv(path, sep =":")
    return tables.query('to_be_loaded == "yes"')


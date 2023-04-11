#importing information of source database from config.py
#sys: exposes all information passed to this script during runtime
#include sys if using environment variables
import sys

#import DB_DETAILS from config.py to get the info of the source database
from config import DB_DETAILS
#import get_tables from util.py to get the tables to be loaded from the table_list.txt
from util import get_tables, load_db_details
from read import read_table
from filter import case_info, create_dataframe

def main():
   #get details about the database
   db_details = load_db_details('dev')
   #
   """
    get_tables(): returns the names of the tables to be read

    The for loop loops through table_list.txt to get names of the tables to be loaded or read_from

    read_table(): will return the data and columns from particular tables suggested to be 
    loaded from tables_list.txt.

    create_dataframe(): will return a dataframe by putting together the data and column names tuple obtained from read_table()
   """
   tables = get_tables('tables_list')
   for table_name in tables['table_name']:
    print('read table from {}'.format(table_name))  
    data, column_name = read_table(db_details, table_name)
    df = create_dataframe(data, column_name)
    
    """case info renders two plots: case percentage and death percentage plot for the countries specified """
   case_info(db_details, "%United States","Italy","%India%","%China%")

if __name__ == '__main__':
    main()
import util
import pandas as pd
from util import get_mysql_connection as getconn
import matplotlib.pyplot as plt
from matplotlib import interactive
#filter
##Looking at toal cases Vs Total deaths
##Likelihood of dying if you got covid in your country
def create_dataframe(data,column_name):
    df = pd.DataFrame(data,columns= column_name)
    return df



def case_info(db_details,*args):
    SOURCE_DB = db_details['SOURCE_DB']
    connection = getconn(db_host = SOURCE_DB['DB_HOST'], db_name= SOURCE_DB['DB_NAME'],
                                       db_user = SOURCE_DB['DB_USER'], db_pass =SOURCE_DB['DB_PASS'])
    
    cursor = connection.cursor()
    df = pd.DataFrame()
    """
    RUN a SQL query on coviddeath table to filter information about covid cases from different countries as specified by the user.
    Generate a dataframe with those information and render two plot: 
        (i)data vs case percentage 
        (ii) data vs death_percentage
    """
    for arg in args:
        query = """SELECT location, population, date, total_cases, total_deaths FROM coviddeaths 
            WHERE coviddeaths.location like "%s" 
            ORDER BY 1,2"""%(arg)
    
        cursor.execute(query)
        data = cursor.fetchall()
        column_names = cursor.column_names
        if df.empty:
            df = create_dataframe(data,column_names)
        else:
            df1 = create_dataframe(data,column_names)
            df = pd.concat([df,df1])
    df['deathPercentage'] = (df.total_deaths / df.total_cases)*100
    df['casePercentage'] = (df.total_cases / df.population)*100 
    df.set_index('date',inplace = True)
    

    fig1 = plt.figure(1)
    df.groupby('location')['deathPercentage'].plot(xlabel = 'date', ylabel = 'death%',title = 'Time vs death%', legend = True)
    fig1.autofmt_xdate(rotation=70)
    
    fig2 = plt.figure(2)
    df.groupby('location')['casePercentage'].plot(xlabel = 'date', ylabel = 'case%',title = 'Time vs case%',legend = True)
    interactive(False)
    fig2.autofmt_xdate(rotation=70)
    plt.show()

    connection.close()


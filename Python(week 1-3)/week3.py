import logging
from week1 import DataLoader #Imported from week1
from week2 import APILoader #Imported from week2 
from sqlalchemy import create_engine  # database and data-handling tools needed to run the full pipeline.
import pandas as pd 


# THE ONLY place logging gets configured in the entire project. DataLoader and APILoader never configure logging themselves
# they just report into whatever setup THIS script provides. This keeps them reusable elsewhere.

logging.basicConfig(
    filename='week3.log',
    level= logging.INFO,
    format='%(asctime)s : %(levelname)s : %(message)s',
    force=True
)

# Prepares (doesn't yet open) the connection to the f1db database.
engine = create_engine('postgresql://postgres:pass123@localhost:5432/f1db')


#CSV pipeline
loader = DataLoader(r'data/fact_race_results.csv') # Creates a DataLoader object pointed at this specific CSV file. 
loader.load() # Actually reads the file into self.data.
loader.clean() # Drops nulls, tracks row counts.
print(loader.data.head())

# Writes the cleaned data into a Postgres table called "race_results."
# if_exists='replace' means wipe and recreate the table if it already exists.
# index=False means don't write pandas' internal row-counter as its own column.
loader.data.to_sql('race_results', engine, if_exists ='replace', index=False) 

logging.info('CSV pipeline complete') #permanent record in the log file,
print('CSV pipeline complete') #visible on screen right now, for you watching it run.


#API pipeline
api = APILoader("api/results.json")
api.fetch() # Fetches live F1 data from the Jolpica-F1 API.


# Digs through the nested JSON response, layer by layer, to reach the actual list of races.
races = api.data['MRData']['RaceTable']['Races'] 

api_df = pd.json_normalize(
    races, # Each race contains ANOTHER nested list - "Results" (one entry per driver).
    record_path='Results',     # record_path tells pandas: explode THIS inner list into individual rows, don't just flatten the outer dictionary.
    
    # Since exploding Results into many rows would normally lose race-level context, meta says: keep these specific outer fields attached to every single row created.
    meta= ['season','round', 'raceName', 'date'] 
)

# The result: one row per driver per race - a proper flat table, instead of a structure with lists-inside-cells that a database can't store.

# Writes the flattened API data into a second Postgres table.
api_df.to_sql('api_race_results', engine, if_exists='replace', index=False)
logging.info('API pipeline completed')
print('API Pipeline Completed')

print(api_df.head())
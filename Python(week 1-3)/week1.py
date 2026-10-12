import pandas as pd #Pandas librabry - Reads CSVs and handles tabular data (DataFrames)

#Brings Python's Built-in logging systems - Report events without deciding where reports saved.
#That decision is made once, elsewhere in whichever script actuallt runs this class
import logging 

logging.basicConfig(
    filename='week1.log',
    level=logging.INFO,
    format='%(asctime)s : %(levelname)s : %(message)s'
)

#Custom error type built on top of Python's built-in Exception class.
# It exists so that "all rows got dropped during cleaning" has its own specific, nameable error - instead of Python throwing a generic, confusing error later when something tries to use an empty dataset.
class EmptyDatasetError(Exception):
     pass

#To load CSV's -> clean CSV's -> inspect CSV's
#Every object created from this class gets its own filepath and data separates from any other DataLoader object
class DataLoader:

#To initiates the DataLoader. Runs automatically the moment a new DataLoader object is created.
    def __init__(self, filepath):
        self.filepath = filepath # Stores the filepath on THIS specific object (instance attribute).

        self.data = None # Starts empty - "no data loaded yet." Gets replaced once load() runs.


 # try/except means: attempt this, but don't crash the whole program if it fails - handle the failure gracefully instead.

    def load(self):
        try:
            self.data = pd.read_csv(self.filepath) # Reads the CSV file and stores the resulting table in self.data.
            logging.info(f'Loaded {self.filepath} Successfully') # Reports a successful load - goes wherever logging is configured.

        except FileNotFoundError:  # Specifically catches "the file doesn't exist at this path" not just any possible error, only this specific, expected one.

            logging.error(f'File Not Found: {self.filepath}') # Reports the failure clearly, instead of letting Python crash with a raw, confusing traceback

        return self.data # Hands back the loaded data (or None, if loading failed) to whoever called this method.

    def clean(self):
        if self.data is None:  # Defensive check: don't even attempt to clean if nothing was ever successfully loaded in the first place.

            logging.error("No data loaded. Call load() first")
            raise ValueError("No data availabel - load() may have failed") # "raise" stops execution here and reports a clear reason why, instead of continuing and failing confusingly two steps later.

        rows_before = len(self.data) # Counts how many rows exist BEFORE cleaning - needed to measure how much data gets removed.

        self.data = self.data.dropna() # Removes any row that has at least one missing (null) value, and SAVES the result back into self.data (critical - printing without saving would throw the cleaned result away).

        rows_after = len(self.data) #Counts rows AFTER cleaning, to compare against rows_before


        if rows_after == 0:
            #If cleaning removed EVERY row, that's a serious problem worth stopping for - not something to silently continue past

            raise EmptyDatasetError(f'All rows dropped during cleaning: {self.filepath}')

        logging.info(f'Dropped {rows_before - rows_after} rows') # Reports exactly how many rows were removed - visible, trackable, not a silent data loss.

        return self.data


    def head(self, n=10):
        if self.data is None:
            logging.error('No data loaded')
            raise ValueError('No data available')

        logging.info('First rows accessed')
        # Returns the first n rows - same defensive None-check pattern as clean().
        return self.data.head(n) 


    def tail(self, n=10):
        if self.data is None:
            logging.error('No data loaded')
            raise ValueError('No data available')

        logging.info('Last rows accessed')
        # Returns the last n rows - same defensive None-check pattern as clean().
        return self.data.tail(n)


    def describe(self):
        if self.data is None:
            logging.error("No data loaded")
            raise ValueError("No data available")

        # Returns statistical summary (mean, std, min, max, etc.) of the data.
        logging.info("Description accessed")
        return self.data.describe()


    def info(self):
        if self.data is None:
            logging.error("No data loaded")
            raise ValueError("No data available")

        # Returns column names, data types, and non-null counts.
        logging.info("Info accessed")
        return self.data.info()

if __name__ == '__main__':
    #Dry Run
    loader = DataLoader(r"data\drivers.csv")
    loader.load()
    loader.clean()
    print(loader.data.head(5))
    print(loader.info())
import pandas as pd 

class DataLoader:

    def __init__(self, filepath):
        self.filepath= filepath
        self.data = None

    def load(self):
        self.data = pd.read_csv(self.filepath)
        print("Data loaded Successfully")
        return self.data 

    def clean(self):
        rows_before = len(self.data)
        self.data = self.data.dropna()
        rows_after = len(self.data)
        print(f'Dropped {rows_before - rows_after} rows')
        return self.data

    def summary(self):
        print(f'Shape: {self.data.shape}')
        print(f"Nulls per column:\n{self.data.isnull().sum()}")


if __name__ == "__main__":
    # This block ONLY runs when you execute dataloader.py directly.
    # It gets completely SKIPPED when imported into another file.
    race_results = DataLoader("data/fact_lap_times.csv")
    r = race_results.load()
    # race_results.clean()
    # race_results.summary()
    print(r.head())
    # print(r.tail())
    # print(r.describe())
    # print(r.info())


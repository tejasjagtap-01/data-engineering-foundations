import requests
import logging

class APILoader:

    def __init__(self, url):
        self.url = url
        self.data = None

    def fetch(self):
        try:
            response = requests.get(self.url)
            if response.status_code == 200:
                self.data = response.json()
                logging.info(f'Fetched {self.url} successfully')
            else:
                logging.error(f'Failed with status code {response.status_code}')
        except requests.exceptions.RequestException as e:
            logging.error(f'Request Failed : {e}')
        return self.data


if __name__ == "__main__":

    # Enable logging output in your terminal
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    api = APILoader("api/results.json")
    api.fetch()

    print("Top level keys:", api.data.keys())
    print("First driver:", api.data['MRData']['RaceTable']['Races'][0]['Results'][0]['Driver']['familyName'])

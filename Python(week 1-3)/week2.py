import requests  #The library that lets Python make web requests - like a browser, but in code.

import logging  #reports events, doesn't configure where they go.

logging.basicConfig(
    filename='week2.log',
    level=logging.INFO,
    format='%(asctime)s : %(levelname)s : %(message)s'
)

class APILoader: # Same shape as DataLoader, But fetches from a URL instead of reading a file

    def __init__(self, url):
        self.url = url      # Stores this specific object's URL.

        self.data = None    # Starts empty until fetch() runs.

    def fetch(self):
        try:
            response = requests.get(self.url) # Sends the actual request to the API - this is the one line that goes out to the internet.

            if response.status_code == 200:  # 200 means "the server responded successfully."
                self.data = response.json()  # Converts the raw response into a Python dictionary and stores it.
                logging.info(f'Fetched {self.url} successfully')

            else:
                # The server responded, but with an error code (404, 500, etc.) it's not a connection problem, the server just said "no."
                logging.error(f'Failed with status code {response.status_code}')

        except requests.exceptions.RequestException as e:
        # This catches a DIFFERENT kind of failure - the request never even reached a server at all (wrong domain, no internet, timeout).
            logging.error(f'Request failed: {e}')

        return self.data

if __name__ == '__main__':
    #Dry Run
    api = APILoader("api/results.json")
    api.fetch()
    # print(api.data)
    print(api.data['MRData']['RaceTable']['Races'][0]['Results'][0]['Driver'])  #API Data Attributes
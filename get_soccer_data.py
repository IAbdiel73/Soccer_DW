
# Fetches data from the SportsDataIO Soccer API, saves it as CSV and JSON,
# and loads the result into a pandas DataFrame.
#
# This function helps automate data ingestion from the Soccer endpoints of the SportsDataIO API.
# The response is saved in both CSV and JSON formats for future reference or offline use.
#
# Returns:
#     A pandas DataFrame containing the parsed API data.
#
# API documentation:
#     https://sportsdata.io/developers/api-documentation/soccer


import requests
import pandas as pd
import json 
from dotenv import load_dotenv, dotenv_values
import os
load_dotenv()
API_KEY = os.getenv("API_KEY")
HEADERS = {"Ocp-Apim-Subscription-Key": API_KEY}

def get_soccer_data(data_class: str, data_group:str, competition:str = None, season:str = None) -> pd.DataFrame:

    # Endpoint
    
    url = f"https://api.sportsdata.io/v4/soccer/{data_class}/json/{data_group}/{competition}/{season}"
    if not isinstance (season, str):
        url = url[:-5]

    print(url)

    # Fetch data
    response = requests.get(url, headers=HEADERS)
    print("Status Code:", response.status_code)

    if response.status_code == 200:
        data = response.json()
    
        # Save to JSON file
        with open(f"Soccer_{data_group}_{competition}_{season}.json", "w") as json_file:
            json.dump(data, json_file, indent=4)
    
        # ✅ Also convert to DataFrame and save to CSV
        df = pd.DataFrame(data)
        df.to_csv("Soccer_{data_group}_{competition}_{season}.csv", index=False)

        print(f"✅ Saved: {data_group}_{competition}_{season}.json and {data_group}_{competition}_{season}.csv")

        return df
    else:
        print("❌ Error fetching data:", response.status_code, response.text)
from os import getenv
# from dotenv import load_dotenv
import requests
from redis_client import r

# load_dotenv()
API_KEY=getenv('API_KEY')

def fetch_flight_schedule(flight_iata):
    url = f"https://aviation-edge.com/v2/public/timetable?key={API_KEY}&type=departure&flight_iata={flight_iata}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            if data:
                flight = data[0]
                return {
                    "flight_no": flight.get("flight", {}).get("iataNumber"),
                    "airline": {
                        "iata": flight.get("airline", {}).get("iataCode"),
                        "name": flight.get("airline", {}).get("name")
                    },
                    "departure": {
                        "iata": flight.get("departure", {}).get("iataCode"),
                        "scheduled_time": flight.get("departure", {}).get("scheduledTime"),
                        "estimated_time": flight.get("departure", {}).get("estimatedTime"),
                        "actual_time": flight.get("departure", {}).get("actualTime"),
                        "delay": flight.get("departure", {}).get("delay"),
                    },
                    "arrival": {
                        "iata": flight.get("arrival", {}).get("iataCode"),
                        "scheduled_time": flight.get("arrival", {}).get("scheduledTime"),
                        "estimated_time": flight.get("arrival", {}).get("estimatedTime"),
                        "actual_time": flight.get("arrival", {}).get("actualTime"),
                        "delay": flight.get("arrival", {}).get("delay"),
                    },
                    "status": flight.get("status"),
                }
        else:
            print(f"Error fetching flight details for {flight_iata}: {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching flight details for {flight_iata}: {e}")
        return None

def fetch_airport_name(iata_code):
    url = f'https://aviation-edge.com/v2/public/airportDatabase?codeIataAirport={iata_code}&key={API_KEY}'
    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            if data:
                airport = data[0]
                return airport.get("nameAirport")
        print(f"Error fetching airport details for {iata_code}: {response.status_code}")
        return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching airport details for {iata_code}: {e}")
        return None
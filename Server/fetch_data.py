from os import getenv
from datetime import datetime
import pytz
# from dotenv import load_dotenv
import requests

# load_dotenv()
API_KEY=getenv('API_KEY')
AIRPORT_API_KEY=getenv('AIRPORT_API_KEY')

timeout = 10

def fetch_flight_schedule(flight_iata, type):
    schedule_url = f"https://aviation-edge.com/v2/public/timetable?key={API_KEY}&type={type}&flight_iata={flight_iata}"
    try:
        response = requests.get(schedule_url, timeout=timeout)
        if response.status_code == 200:
            data = response.json()

            if isinstance(data, dict) and data.get("error") == "No Record Found" and not data.get("success"):
                print(f"No record found for flight {flight_iata}, type {type}")
                return None
            
            if data:
                flight = data[0]
                return {
                    "flight_no": flight.get("flight", {}).get("iataNumber"),
                    "airline": {
                        "iata": flight.get("airline", {}).get("iataCode", "N/A"),
                        "name": flight.get("airline", {}).get("name", "Unknown")
                    },
                    "departure": {
                        "iata": flight.get("departure", {}).get("iataCode"),
                        "scheduled_time": flight.get("departure", {}).get("scheduledTime"),
                        "estimated_time": flight.get("departure", {}).get("estimatedTime"),
                        "actual_time": flight.get("departure", {}).get("actualTime"),
                        "delay": int(flight.get("departure", {}).get("delay")),
                    },
                    "arrival": {
                        "iata": flight.get("arrival", {}).get("iataCode"),
                        "scheduled_time": flight.get("arrival", {}).get("scheduledTime"),
                        "estimated_time": flight.get("arrival", {}).get("estimatedTime"),
                        "actual_time": flight.get("arrival", {}).get("actualTime"),
                        "delay": int(flight.get("arrival", {}).get("delay")),
                    },
                    "status": flight.get("status"),
                }
        else:
            print(f"Error fetching flight details for {flight_iata}: {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching flight details for {flight_iata}: {e}")
        return None
    
def fetch_flight_live_details(iata_code):
    flight_url = f'https://aviation-edge.com/v2/public/flights?key={API_KEY}&flightIata={iata_code}'
    try:
        response = requests.get(flight_url, timeout=timeout)
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list) and data:
                flight = data[0]
                return {
                    "speed": {
                        "vertical": flight.get("speed", {}).get("vspeed"),
                        "horizontal":flight.get("speed", {}).get("horizontal"),
                    },
                    "geography": {
                        "altitude":flight.get("geography", {}).get("altitude"),
                        "direction":flight.get("geography", {}).get("direction"),
                        "latitude":flight.get("geography", {}).get("latitude"),
                        "longitude":flight.get("geography", {}).get("longitude")
                    }
                }
            elif isinstance(data, dict) and data.get("error") == "No Record Found":
                print(f"No live details found for flight {iata_code}")
                return None
            else:
                print(f"Unexpected response structure for flight {iata_code}: {data}")
                return None
        else:
            print(f"Error fetching flight live details for {iata_code}: {response.status_code}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching flight live details for {iata_code}: {e}")
        return None

def fetch_airport_details(iata_code):
    # airport_url = f'https://aviation-edge.com/v2/public/airportDatabase?codeIataAirport={iata_code}&key={API_KEY}'
    airport_url = f"https://api.api-ninjas.com/v1/airports?iata={iata_code}"
    try:
        response = requests.get(airport_url, headers={'X-Api-Key': AIRPORT_API_KEY}, timeout=timeout)
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list) and data:
                airport = data[0]
                return {
                    "name": airport.get("name", {}),
                    "country": airport.get("country", {}),
                    "timezone": airport.get("timezone", {}),
                    "latitude": float(airport.get("latitude", {})),
                    "longitude": float(airport.get("longitude", {})),
                }
        print(f"Error fetching airport details for {iata_code}: {response.status_code}")
        return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching airport details for {iata_code}: {e}")
        return None

def get_airline_image(iata):
    airline_url = f"https://api.api-ninjas.com/v1/airlines?iata={iata}"
    try:
        response = requests.get(airline_url, headers={'X-Api-Key': AIRPORT_API_KEY}, timeout=timeout)
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list) and data:
                airline = data[0]
                return airline.get("logo_url", "")
        print(f"Error fetching airline logo for {iata}: {response.status_code}")
        return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching airport details for {iata}: {e}")
        return None

def calculate_flying_mins(departure_time, arrival_time, departure_timezone, arrival_timezone):
    departure_dt = datetime.strptime(departure_time, "%Y-%m-%dT%H:%M:%S.%f")
    arrival_dt = datetime.strptime(arrival_time, "%Y-%m-%dT%H:%M:%S.%f")
    
    departure_tz = pytz.timezone(departure_timezone)
    arrival_tz = pytz.timezone(arrival_timezone)

    localized_departure_dt = departure_tz.localize(departure_dt)
    localized_arrival_dt = arrival_tz.localize(arrival_dt)

    utc_departure_dt = localized_departure_dt.astimezone(pytz.utc)
    utc_arrival_dt = localized_arrival_dt.astimezone(pytz.utc)

    flying_duration = utc_arrival_dt - utc_departure_dt
    flying_mins = flying_duration.total_seconds() // 60
    
    return int(flying_mins)
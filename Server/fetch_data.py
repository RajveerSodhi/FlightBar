from os import getenv
# from dotenv import load_dotenv
import requests

# load_dotenv()
API_KEY=getenv('API_KEY')
AIRPORTS_API_KEY=getenv('AIRPORTS_API_KEY')

def fetch_flight_schedule(flight_iata, type):
    schedule_url = f"https://aviation-edge.com/v2/public/timetable?key={API_KEY}&type={type}&flight_iata={flight_iata}"
    try:
        response = requests.get(schedule_url)
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
    
def fetch_flight_live_details(iata_code):
    flight_url = f'https://aviation-edge.com/v2/public/flights?key={API_KEY}&flightIata={iata_code}'
    try:
        response = requests.get(flight_url)
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

def fetch_airport_name(iata_code):
    # airport_url = f'https://aviation-edge.com/v2/public/airportDatabase?codeIataAirport={iata_code}&key={API_KEY}'
    airport_url = f"https://api.api-ninjas.com/v1/airports?iata={iata_code}"
    try:
        print(AIRPORTS_API_KEY)
        response = requests.get(airport_url, headers={'X-Api-Key': AIRPORTS_API_KEY})
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list) and data:
                airport = data[0]
                return airport.get("name")
        print(f"Error fetching airport details for {iata_code}: {response.status_code}")
        return None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching airport details for {iata_code}: {e}")
        return None
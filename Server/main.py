from os import getenv
from datetime import datetime, timezone
import json
import time
from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from fetch_data import fetch_flight_schedule, fetch_airport_details, fetch_flight_live_details, calculate_flying_mins
from redis_client import cache

load_dotenv()
REQ_KEY = getenv('REQ_KEY')

app = FastAPI(
    title="FlightBar Server",
    version=1.0,
    docs_url=None
)

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def retry_on_failure(func, retries=3, delay=2, *args, **kwargs):
    for attempt in range(retries):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(delay)
                continue
            raise e

# Root Endpoint
@app.get("/", include_in_schema=False)
def root():
    return {
        "redis_conn_status": cache.ping()
    }

'''

To Do:

1. limit calling flight schedule API.
Call when:
a) If requested before takeoff
- Flight is scheduled: get scheduled take off and landing time, keep updating to get estimated times and delay
- Flight is en-route: get actual take off time (1)
- Flight has landed: get actual landing time
b) If requested after takeoff

2. Add notifications for flight status change

3. Custom symbols for flight status

4. Figure out if flight is > 10hours

5. Airline Logo from Ninja API integration

'''

async def validate_secret_key(x_key: str = Header(...)):
    if x_key != REQ_KEY:
        raise HTTPException(status_code=401, detail="Invalid Secret Key")
    return x_key

@app.post("/flight")
def get_flight_data(iata, key: str = Depends(validate_secret_key)):
    '''
        Private endpoint for the FlightBar app that fetches and caches flight information from external APIs.
        Returns a JSON object with relevant flight tracking information.
    '''
    if not key:
        raise HTTPException(status_code=401, detail="No Secret Key Provided")
    
    iata = iata.upper()
    try:
        # if cached data, return that
        cached_data = cache.get(f"FLIGHT_{iata}")
        if cached_data:
            return json.loads(cached_data)

        # Flight Schedule Details
        flight_data = fetch_flight_schedule(iata, "departure")
        # flight_data = retry_on_failure(fetch_flight_schedule, iata, "departure")
        print(f"Fetching schedule for {iata} as departure")
        if not flight_data:
            print(f"No data found for departure. Trying arrival for {iata}")
            flight_data = fetch_flight_schedule(iata, "arrival")
        if not flight_data:
            raise HTTPException(status_code=404, detail="Flight Schedule details not found")
        print("schedule found!")

        # Flight Live Details (optional)
        if flight_data["status"] == "active":
            print("fetching flight live details.")
            # flight_live_details = retry_on_failure(fetch_flight_live_details, iata)
            flight_live_details = fetch_flight_live_details(iata)
            print("live details function returned!")

            flight_data["speed"] = flight_live_details.get("speed", {
                "vertical": None,
                "horizontal": None
            }) if flight_live_details else {"vertical": None, "horizontal": None}

            flight_data["geography"] = flight_live_details.get("geography", {
                "altitude": None,
                "direction": None,
                "latitude": None,
                "longitude": None
            }) if flight_live_details else {
                "altitude": None,
                "direction": None,
                "latitude": None,
                "longitude": None
            }
            print("live details found!")

        # Airport Details
        for airport_type in ["arrival", "departure"]:
            airport_iata = flight_data.get(airport_type).get("iata")
            if airport_iata:
                cached_airport_data = cache.get(f"AIRPORT_{airport_iata}")
                if cached_airport_data:
                    flight_data[f"{airport_type}"]["persistent"] = json.loads(cached_airport_data)
                else:
                    airport_details = fetch_airport_details(airport_iata)
                    # airport_name = retry_on_failure(fetch_airport_details, airport_iata)
                    if not airport_details:
                        raise HTTPException(status_code=404, detail="Airport details not found")
                    
                    flight_data[f"{airport_type}"]["persistent"] = airport_details.get(f"{airport_type}", {
                        "name": None,
                        "country": None,
                        "timezone": None,
                        "latitude": None,
                        "longitude": None
                    })

                    cache.set(f"AIRPORT_{airport_iata}", json.dumps(airport_details))
            print(f"{airport_type} airport details found!")

        timestamp = datetime.now(timezone.utc)
        flight_data["timestamp"] = str(timestamp)

        # get flying time
        flight_mins = calculate_flying_mins(flight_data["departure"]["scheduled_time"], flight_data["arrival"]["scheduled_time"], flight_data["departure"]["persistent"]["timezone"], flight_data["arrival"]["persistent"]["timezone"])
        flight_hours = int(flight_mins / 60)

        # get refresh interval
        cache_ttl_mins = 24 if flight_hours <= 4 else 48
        cache_ttl_secs = (cache_ttl_mins - 1) * 60

        flight_data["flight_mins"] = flight_mins

        cache.setex(f"FLIGHT_{iata}", cache_ttl_secs, json.dumps(flight_data))

        return flight_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected Error: {str(e)}")

@app.get("/test")
def get_test():
    return {
    "flight_no": "AC39",
    "airline": {
        "iata": "AC",
        "name": "Air Canada"
    },
    "departure": {
        "iata": "YVR",
        "scheduled_time": "2025-01-15T23:45:00.000",
        "estimated_time": "2025-01-16T00:30:00.000",
        "actual_time": "2025-01-16T00:19:00.000",
        "delay": "35",
        "name": "Vancouver International"
    },
    "arrival": {
        "iata": "AKL",
        "scheduled_time": "2025-01-17T11:00:00.000",
        "estimated_time": "2025-01-17T10:43:00.000",
        "actual_time": "2025-01-17T10:51:00.000",
        "delay": 5,
        "name": "Auckland International"
    },
    "status": "landed",
    "speed": {
        "vertical": 0.0,
        "horizontal": 0.0
    },
    "geography": {
        "altitude": 0.0,
        "direction": 0.0,
        "latitude": 0.0,
        "longitude": 0.0
    },
    "timestamp": "2025-01-22 02:59:13.421799+00:00",
    "flight_mins": 0
}

# Resposne Format:

# {
#   "flight_no": "AC39",
#   "airline": {
#     "iata": "AC",
#     "name": "Air Canada"
#   },
#   "departure": {
#     "iata": "YVR",
#     "scheduled_time": "2025-01-15T23:45:00.000",
#     "estimated_time": "2025-01-16T00:30:00.000",
#     "actual_time": "2025-01-16T00:19:00.000",
#     "delay": "35",
#     "name": "Vancouver International"
#   },
#   "arrival": {
#     "iata": "AKL",
#     "scheduled_time": "2025-01-17T11:00:00.000",
#     "estimated_time": "2025-01-17T10:43:00.000",
#     "actual_time": "2025-01-17T10:46:00.000",
#     "delay": null,
#     "name": "Auckland International"
#   },
#   "status": "landed",
#   "speed": {
#     "vertical": null,
#     "horizontal": null
#   },
#   "geography": {
#     "altitude": null,
#     "direction": null,
#     "latitude": null,
#     "longitude": null
#   },
#   "timestamp": "2025-01-22 02:59:13.421799+00:00",
#   "flight_mins": 0
# }
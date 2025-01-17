from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fetch_data import fetch_flight_schedule, fetch_airport_name, fetch_flight_live_details
import json
from redis_client import cache

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

cache_TTL_mins = 50
cache_TTL_secs = cache_TTL_mins * 60

# Root Endpoint
@app.get("/", include_in_schema=False)
def root():
    return {
        "redis_conn_status": cache.ping()
    }


'''

Optimizing API calls:

1. call for airport code to name from another API, potentially free
2. limit calling of flight schedule API.
Call when:
a) If requested before takeoff
- Flight is scheduled: get scheduled take off and landing time, keep updating to get estimated times and delay
- Flight is en-route: get actual take off time (1)
- Flight has landed: get actual landing time

'''


@app.get("/flight")
def get_flight_data(iata):
    try:
        cached_data = cache.get(f"FLIGHT_{iata}")
        if cached_data:
            return json.loads(cached_data)

        # Flight Schedule Details
        flight_data = fetch_flight_schedule(iata, "departure")
        print(f"Fetching schedule for {iata} as departure")
        if not flight_data:
            print(f"No data found for departure. Trying arrival for {iata}")
            flight_data = fetch_flight_schedule(iata, "arrival")
        if not flight_data:
            raise HTTPException(status_code=404, detail="Flight Schedule details not found")
        print("schedule found!")

        # Flight Live Details
        if flight_data["status"] != "active":
            print("fetching flight live details.")
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
                    flight_data[f"{airport_type}"]["name"] = json.loads(cached_airport_data)
                else:
                    airport_name = fetch_airport_name(airport_iata)
                    if not airport_name:
                        raise HTTPException(status_code=404, detail="Airport details not found")
                    
                    flight_data[f"{airport_type}"]["name"] = airport_name
                    cache.set(f"AIRPORT_{airport_iata}", json.dumps(airport_name))
            print("airports found!")

        cache.setex(f"FLIGHT_{iata}", 3600, json.dumps(flight_data))

        return flight_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected Error: {str(e)}")
    

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
#   }
# }
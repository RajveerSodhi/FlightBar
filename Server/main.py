from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fetch_data import fetch_flight_schedule, fetch_airport_name, fetch_flight_live_details
import json
from redis_client import cache

app = FastAPI(
    title="FlightBar Server"
)

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Root Endpoint
@app.get("/")
def root():
    return {cache.ping()}

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
        print("fetching flight live details.")
        flight_live_details = fetch_flight_live_details(iata)
        print("live details function returned!")
        if not flight_live_details:
            print("Error getting live details.")
            raise HTTPException(status_code=404, detail="Flight Live details not found")
        
        flight_data["speed"] = flight_live_details.get("speed", {})
        flight_data["geography"] =flight_live_details.get("geography", {})
        print("live details found!")

        # Airport Details
        for airport_type in ["arrival", "departure"]:
            airport_iata = flight_data.get(airport_type).get("iata")
            if airport_iata:
                cached_airport_data = cache.get(f"AIRPORT_{airport_iata}")
                if cached_airport_data:
                    flight_data[f"{airport_type}"] = json.loads(cached_airport_data)
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
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fetch_data import fetch_flight_schedule, fetch_airport_name
from redis_client import r
import json

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
    return {"FlightBar server"}

@app.get("/flight")
def get_flight_data(iata):
    try:
        cached_data = r.get(f"FLIGHT_{iata}")
        if cached_data:
            return json.loads(cached_data)

        # Flight details
        flight_data = fetch_flight_schedule(iata)
        if not flight_data:
            raise HTTPException(status_code=404, detail="Flight details not found")

        # Airport details
        for airport_type in ["arrival", "departure"]:
            airport_iata = flight_data.get(airport_type).get("iata")
            if airport_iata:
                cached_airport_data = r.get(f"AIRPORT_{airport_iata}")
                if cached_airport_data:
                    flight_data[f"{airport_type}"] = json.loads(cached_airport_data)
                else:
                    airport_name = fetch_airport_name(airport_iata)
                    if not airport_name:
                        raise HTTPException(status_code=404, detail="Airport name not found")
                    
                    flight_data[f"{airport_type}"]["name"] = airport_name
                    r.set(f"AIRPORT_{airport_iata}", json.dumps(airport_name))

        r.setex(f"FLIGHT_{iata}", 3600, json.dumps(flight_data))

        return flight_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
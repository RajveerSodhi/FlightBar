//
//  DetailsView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2024-06-18.
//

import SwiftUI
import MapKit

struct DetailsView: View {
    @State private var flightNumber: String = ""
    @EnvironmentObject var flightViewModel: FlightViewModel
    
    var body: some View {
        VStack(alignment:.center, spacing: 10) {
            if let flight = flightViewModel.flight {
            
                let flightPos = CLLocationCoordinate2D(latitude: flight.live?.latitude ?? 0, longitude: flight.live?.longitude ?? 0)
                @State var camera: MapCameraPosition = .region(MKCoordinateRegion(center: flightPos, latitudinalMeters: 500000, longitudinalMeters: 500000))
                
                VStack(spacing: 5) {
                    Text("\(flight.airline.name) \(flight.flight.iata)")
                        .font(.headline)
                    Text((flight.flightStatus))
                        .font(.subheadline)
                    
                    Map(position: $camera) {
                        Annotation((flight.flight.iata), coordinate: flightPos) {
                            Image(systemName: "airplane")
                                .foregroundStyle(.white)
                                .padding()
                                .background(.red)
                                .cornerRadius(10)
                        }
                    }
                        .frame(height:120)
                        .cornerRadius(15)
                    
                    Divider()
                    
                    Text("Departure")
                        .font(.headline)
                    
                    Text("Airport: \(flight.departure.airport)")
                    Text("Time: \(flight.departure.scheduled ?? "N/A")")
                    
                    Divider()
                    
                    Text("Arrival")
                        .font(.headline)
                    
                    Text("Airport: \(flight.arrival.airport)")
                    Text("Time: \(flight.arrival.scheduled ?? "N/A")")
                    Text("Gate: \(flight.arrival.gate ?? "N/A")")
                    Text("Baggage Claim: \(flight.arrival.baggage ?? "N/A")")
                    Text("Delay: \(flight.arrival.delay ?? 0) minutes")
                    
                    Divider()
                    
                    if let live = flight.live {
                        Text("Current Flight Status")
                            .font(.headline)
                        
                        Text("Latitude: \(live.latitude)")
                        Text("Longitude: \(live.longitude)")
                        Text("Altitude: \(live.altitude) meters")
                        Text("Ground Speed: \(live.speedHorizontal) km/h")
                        Text("Vertical Speed: \(live.speedVertical) m/s")
                    }
                }
            } else {
                Text("Loading flight details...")
            }
            
            Divider()
            
            TextField("Enter Flight Number", text: $flightNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .trailing])
            
            Button(action: {
                flightViewModel.fetchFlightDetails(for: flightNumber)
            }) {
                Text("Fetch Flight Details")
            }
            .padding()
        }
        .padding()
        .frame(width: 360)
        .onAppear {
            flightNumber = flightViewModel.storedFlightNumber
            flightViewModel.fetchFlightDetails(for: flightNumber)
        }
    }
}


#Preview {
    DetailsView()
}

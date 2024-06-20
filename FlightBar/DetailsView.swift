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
    
    func fixAirportName(name: String) -> String {
        let words = name.split(separator: " ")
        let newNameArray: [String] = words.map { word in
            if word.uppercased() == "INTERNATIONAL" {
                return "Intl"
            } else {
                return String(word)
            }
        }
        let newName = newNameArray.joined(separator: " ")
        
        return newName
    }
    
    func fixTime(dateTime: String) -> String {
        
        if dateTime == "N/A" {
            return dateTime
        }
        
        var time = dateTime.split(separator: "T")[1]
        time = time.split(separator: "+")[0]
        let newTime = time.dropLast(3)
        
        return String(newTime)
    }
    
    var body: some View {
        VStack(alignment:.center, spacing: 10) {
            if let flight = flightViewModel.flight {
            
                let flightPos = CLLocationCoordinate2D(latitude: flight.live?.latitude ?? 0, longitude: flight.live?.longitude ?? 0)
                @State var camera: MapCameraPosition = .region(MKCoordinateRegion(center: flightPos, latitudinalMeters: 500000, longitudinalMeters: 500000))
                
                let airline = flight.airline.name.capitalized
                let status = flight.flightStatus.capitalized
                let flightNo = flight.flight.iata.uppercased()
                let departureAirportCode = flight.departure.iata.uppercased()
                let departureAirport = fixAirportName(name: flight.departure.airport)
                let arrivalAirportCode = flight.arrival.iata.uppercased()
                let arrivalAirport = fixAirportName(name: flight.arrival.airport)
                let departureScheduled = fixTime(dateTime: flight.departure.scheduled ?? "N/A")
                let arrivalScheduled = fixTime(dateTime:flight.arrival.scheduled ?? "N/A")
                let departureActual = fixTime(dateTime:flight.departure.actual ?? "N/A")
                let arrivalActual = fixTime(dateTime:flight.arrival.actual ?? "N/A")
                let departureEstimated = fixTime(dateTime:flight.departure.estimated ?? "N/A")
                let arrivalEstimated = fixTime(dateTime:flight.arrival.estimated ?? "N/A")
                
                VStack(spacing: 5) {
                    Text("\(airline) - \(flightNo)")
                        .font(.headline)
                    Text((status))
                        .font(.subheadline)
                    
                    Map(position: $camera) {
                        Annotation((flightNo), coordinate: flightPos) {
                            Image(systemName: "airplane")
                                .foregroundStyle(.white)
                                .padding()
                                .background(.red)
                                .cornerRadius(10)
                        }
                    }
                        .frame(height:140)
                        .cornerRadius(15)
                    
                    Spacer()
                    
                    HStack {
                        VStack {
                            Text(departureAirportCode)
                                .font(.headline)
                            Text(departureAirport)
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#787878"))
                                .frame(width: 100)
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                VStack {
                                    Text(departureScheduled)
                                    Text("SCHD")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#787878"))
                                }
                                
                                Spacer()
                                
                                VStack {
                                    if ((departureActual) != "N/A") {
                                        Text(departureActual)
                                        Text("ACTL")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#787878"))
                                    }
                                    else {
                                        Text(departureEstimated)
                                        Text("ESTD")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#787878"))
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .foregroundColor(.black)
                        .padding()
                        .background(Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        )
                        
                        Spacer()
                        Image(systemName: "arrow.forward")
                        Spacer()
                        
                        VStack {
                            Text(arrivalAirportCode)
                                .font(.headline)
                            Text(arrivalAirport)
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#787878"))
                                .frame(width: 100)
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                VStack {
                                    Text(arrivalScheduled)
                                    Text("SCHD")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#787878"))
                                }
                                
                                Spacer()
                                
                                VStack {
                                    if ((arrivalActual) != "N/A") {
                                        Text(arrivalActual)
                                        Text("ACTL")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#787878"))
                                    }
                                    else {
                                        Text(arrivalEstimated)
                                        Text("ESTD")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#787878"))
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .foregroundColor(.black)
                        .padding()
                        .background(Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        )
                    }
                    
                    Text("Timezone: UTC")
                        .font(.caption)
                    
                    Spacer()
                    
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
        .frame(width: 420)
        .onAppear {
            flightNumber = flightViewModel.storedFlightNumber
            flightViewModel.fetchFlightDetails(for: flightNumber)
        }
    }
}

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
        
        return newNameArray.joined(separator: " ")
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
                let lastUpdated = fixTime(dateTime: flight.live?.updated ?? "N/A")
                let latitude =  String((flight.live?.latitude ?? 0.0).rounded()) + "°"
                let longitude =  String((flight.live?.longitude ?? 0.0).rounded()) + "°"
                let altitude =  String((flight.live?.altitude ?? 0.0).rounded()) + "m"
                let speedX = String((flight.live?.speedHorizontal ?? 0.0).rounded()) + "km/h"
                let speedY = String((flight.live?.speedVertical ?? 0.0).rounded()) + "km/h"
                let direction = String((flight.live?.direction ?? 0.0).rounded()) + "°"
                
                let flightPos = CLLocationCoordinate2D(latitude: flight.live?.latitude ?? 0.0, longitude: flight.live?.longitude ?? 0.0)
                @State var camera: MapCameraPosition = .region(MKCoordinateRegion(center: flightPos, latitudinalMeters: 500000, longitudinalMeters: 500000))
                
                VStack(spacing: 5) {
                    Text("\(airline) - \(flightNo)")
                        .font(.title2)
                    Text((status))
                        .font(.headline)
                    
                    Spacer()
                    
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
                                .font(.title3)
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
                                .font(.title3)
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
                    
                    if flight.live == nil {
                        
                        Spacer()
                        
                        HStack {
                            VStack {
                                HStack {
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text(latitude)
                                        Text("LAT")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#787878"))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text(longitude)
                                        Text("LONG")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#787878"))
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Rectangle()
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                )
                                .padding(3)
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text(speedY)
                                        Text("SPD (Ver)")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#787878"))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text(speedX)
                                        Text("SPD (Hor)")
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "#787878"))
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Rectangle()
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                )
                                .padding(3)
                            }
                            
                            VStack {
                                Spacer()
                            
                                Text(altitude)
                                    .padding(.top, 4)
                                Text("ALT")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "#787878"))
                                    .padding(.bottom, 6)
                                    .padding([.trailing, .leading])
                                
                                Spacer()
                                
                                Text(direction)
                                    .padding(.top, 6)
                                Text("DIR")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "#787878"))
                                    .padding(.bottom, 4)
                                    .padding([.trailing, .leading])
                            
                                Spacer()
                            }
                                .foregroundColor(.black)
                                .padding()
                                .background(Rectangle()
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    let message = flight.live != nil ? ". Last Updated: \(lastUpdated)" : ""
                    Text("All times in UTC\(message)")
                        .font(.footnote)
                        .padding(.top, 5)
                    
                }
            } else {
                Text("Loading flight details...")
            }
            
            Divider()
            
            Text("Edit Flight Number")
                .font(.headline)
            
            HStack {
                TextField("Enter Flight Number", text: $flightNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing, 5)
                
                Button(action: {
                    flightViewModel.fetchFlightDetails(for: flightNumber)
                }) {
                    Image(systemName: "magnifyingglass")
                }
            }
            
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            flightNumber = flightViewModel.storedFlightNumber
            flightViewModel.fetchFlightDetails(for: flightNumber)
        }
    }
}

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
        VStack(alignment: .center, spacing: 10) {
            if let errorMessage = flightViewModel.errorMessage {
                Text(errorMessage)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                } else if let flight = flightViewModel.flight {
                let airline = flight.airline.name.capitalized
                let flightNo = flight.flightNo.uppercased()
                let status = flight.status.capitalized
                let departureScheduled = fixTime(dateTime: flight.departure.scheduledTime ?? "N/A")
                let departureEstimated = fixTime(dateTime: flight.departure.estimatedTime ?? "N/A")
                let departureActual = fixTime(dateTime: flight.departure.actualTime ?? "N/A")
                let arrivalScheduled = fixTime(dateTime: flight.arrival.scheduledTime ?? "N/A")
                let arrivalEstimated = fixTime(dateTime: flight.arrival.estimatedTime ?? "N/A")
                let arrivalActual = fixTime(dateTime: flight.arrival.actualTime ?? "N/A")

                    VStack {
                        Text("\(airline) - \(flightNo)").font(.title2)
                        Text(status).font(.headline)
                        
                        if flight.geography?.altitude != nil  {
                            let geography = flight.geography
                            let speed = flight.speed
                            
                            let flightPos = CLLocationCoordinate2D(latitude: geography?.latitude ?? 49.884491,
                                                                   longitude: geography?.longitude ?? -119.493500)
                            let flightSpan = MKCoordinateSpan(latitudeDelta: 0.65, longitudeDelta: 0.65)
                            let flightRegion = MKCoordinateRegion(center: flightPos, span: flightSpan)
                            let flightAngle = geography?.direction ?? 0.0
                            
                            @State var flightCamera: MapCameraPosition = .region(flightRegion)
                            
                            Map(position: $flightCamera) {
                                Annotation(flightNo, coordinate: flightPos) {
                                    Image(systemName: "airplane")
                                        .resizable()
                                        .imageScale(.large)
                                        .foregroundStyle(.black)
                                        .shadow(color: .white, radius: 3)
                                        .rotationEffect(Angle(degrees: flightAngle))
                                }
                            }
                            .frame(height: 140)
                            .cornerRadius(15)
                        } else {
                        }
                        
                        HStack {
                            VStack {
                                Text(flight.departure.iata.uppercased())
                                    .font(.title3)
                                Text(fixAirportName(name: flight.departure.name))
                                    .font(.subheadline)
                                
                                HStack {
                                    VStack {
                                        Text(departureScheduled).font(.body)
                                        Text("SCHD").font(.caption).foregroundColor(.gray)
                                    }
                                    
                                    VStack {
                                        if departureActual != "N/A" {
                                            Text(departureActual).font(.body)
                                            Text("ACTL").font(.caption).foregroundColor(.gray)
                                        } else {
                                            Text(departureEstimated).font(.body)
                                            Text("ESTD").font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            
                            VStack {
                                Text(flight.arrival.iata.uppercased())
                                    .font(.title3)
                                Text(fixAirportName(name: flight.arrival.name))
                                    .font(.subheadline)
                                
                                HStack {
                                    VStack {
                                        Text(arrivalScheduled).font(.body)
                                        Text("SCHD").font(.caption).foregroundColor(.gray)
                                    }
                                    
                                    VStack {
                                        if arrivalActual != "N/A" {
                                            Text(arrivalActual).font(.body)
                                            Text("ACTL").font(.caption).foregroundColor(.gray)
                                        } else {
                                            Text(arrivalEstimated).font(.body)
                                            Text("ESTD").font(.caption).foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        if flight.geography?.altitude != nil  {
                            let geography = flight.geography
                            let speed = flight.speed
                            
                            let latitude = String(format: "%.1f", geography?.latitude ?? 0.0)
                            let longitude = String(format: "%.1f", geography?.longitude ?? 0.0)
                            let altitude = Int(geography?.altitude?.rounded() ?? 0)
                            let hspeed = Int(speed?.horizontal?.rounded() ?? 0)
                            let vspeed = Int(speed?.vertical?.rounded() ?? 0)
                            
                            VStack {
                                Text("Latitude: \(latitude)")
                                Text("Longitude: \(longitude)")
                                Text("Altitude: \(altitude)m")
                                Text("Horizontal Speed: \(hspeed) km/h")
                                Text("Vertical Speed: \(vspeed) km/h")
                            }
                            .font(.body)
                        } else {
                            Text("Tracking data only available while in flight")
                                .foregroundColor(.gray)
                                .padding(5)
                        }
                    }
            } else {
                Text("Flight details unavailable").foregroundColor(.red)
            }

            Divider()
            Text("Enter Flight Number").font(.headline)

            HStack {
                TextField("Flight Number", text: $flightNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing, 5)
                Button(action: {
                    flightViewModel.startAutoRefresh(flightNumber: flightNumber)
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }.padding()
        }.padding()
    }
}

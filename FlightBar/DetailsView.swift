import SwiftUI
import MapKit
import Foundation

struct DetailsView: View {
    @State private var flightNumber: String = ""
    @State private var isLoaded: Bool = true
    @EnvironmentObject var flightViewModel: FlightViewModel

    func fixAirportName(name: String) -> String {
        let words = name.split(separator: " ")
        let newNameArray: [String] = words.map { word in
            if word.uppercased() == "INTERNATIONAL" { return "Intl" }
            else if word.uppercased() == "AIRPORT" { return "Airp." }
            else { return String(word) }
        }
        
        return newNameArray.joined(separator: " ")
    }
        
    func fixTime(dateTime: String) -> String {
        if dateTime == "N/A" { return dateTime }
        
        var time = dateTime.split(separator: "T")[1]
        time = time.split(separator: "+")[0]
        let newTime = time.dropLast(3)
        
        return String(newTime)
    }
    
    func timeAgo(timestamp: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSXXX"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let utcDate = formatter.date(from: timestamp) else {
            return "Invalid timestamp"
        }
        
        let now = Date()
        
        // Calculate the difference in minutes
        let timeDifference = Int(now.timeIntervalSince(utcDate)) / 60
        if timeDifference < 1 {
            return "Last updated: just now"
        } else {
            return "Last updated: \(timeDifference) minutes ago"
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if let errorMessage = flightViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(5)
                } else if let flight = flightViewModel.flight {
                    
                    // Misc flight info
                    let airline = flight.airline.name.capitalized
                    let flightNo = flight.flightNo.uppercased()
                    let status = flight.status.capitalized
                    let lastUpdatedText = timeAgo(timestamp: flight.timestamp)
                    let flightMins = flight.flightMins
                    let flightHours = Int(flightMins / 60)
                    let latLongDelta = flightHours <= 4 ? 1.2 : 2.8
                    
                    // Departure Airport info
                    let departureName = fixAirportName(name: flight.departure.persistent.name ?? "N/A")
                    let departureScheduled = fixTime(dateTime: flight.departure.scheduledTime ?? "N/A")
                    let departureEstimated = fixTime(dateTime: flight.departure.estimatedTime ?? "N/A")
                    let departureActual = fixTime(dateTime: flight.departure.actualTime ?? "N/A")
                    let departureIata = flight.departure.iata.uppercased() ?? "N/A"
                    let departureLat = Double(flight.departure.persistent.latitude ?? "49.884491")
                    let departureLong = Double(flight.departure.persistent.longitude ?? "-119.493500")
                    
                    // Arrival Airport info
                    let arrivalName = fixAirportName(name: flight.arrival.persistent.name ?? "N/A")
                    let arrivalScheduled = fixTime(dateTime: flight.arrival.scheduledTime ?? "N/A")
                    let arrivalEstimated = fixTime(dateTime: flight.arrival.estimatedTime ?? "N/A")
                    let arrivalActual = fixTime(dateTime: flight.arrival.actualTime ?? "N/A")
                    let arrivalIata = flight.arrival.iata.uppercased() ?? "N/A"
                    let arrivalLat = Double(flight.arrival.persistent.latitude ?? "49.884491")
                    let arrivalLong = Double(flight.arrival.persistent.longitude ?? "-119.493500")
                    
                    // Flight Map info
                    let flightLat = flight.geography?.latitude ?? 49.884491
                    let flightLong = flight.geography?.longitude ?? -119.493500
                    let flightAngle = ((flight.geography?.direction ?? 0.0) - 90)

                    VStack {
                        Text("\(airline) - \(flightNo)").font(.title2)
                        Text(status).font(.headline)
                        
                        if flight.geography?.altitude != nil  {
                            let flightPos = CLLocationCoordinate2D(latitude: flightLat,
                                                                   longitude: flightLong)
                            
                            
                            
                            let flightSpan = MKCoordinateSpan(latitudeDelta: latLongDelta, longitudeDelta: latLongDelta)
                            let flightRegion = MKCoordinateRegion(center: flightPos, span: flightSpan)
                            
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
                            .frame(height: 150)
                            .cornerRadius(15)
                        } else {
                        }
                        
                        HStack {
                            VStack {
                                Text(departureIata)
                                    .font(.title3)
                                Text(departureName)
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
                                Text(arrivalIata)
                                    .font(.title3)
                                Text(arrivalName)
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
                        Text(lastUpdatedText)
                            .foregroundColor(.gray)
                            .italic(true)
                    }
                }
            else {
                Text("Enter a flight number to get started").foregroundColor(.gray)
            }

            Divider()
            Text("Enter Flight Number").font(.headline)

            HStack {
                TextField("Flight Number", text: $flightNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .padding(.trailing, 5)
                    .onSubmit {
                        flightNumber = flightNumber.uppercased()
                        isLoaded = false
                        flightViewModel.startAutoRefresh(flightNumber: flightNumber) {
                            isLoaded = true
                        }
                    }
                Button(action: {
                    flightNumber = flightNumber.uppercased()
                    isLoaded = false
                    flightViewModel.startAutoRefresh(flightNumber: flightNumber) {
                        isLoaded = true
                    }
                }) {
                    if flightNumber != "" && isLoaded != true {
//                        Image(systemName: "circle.dotted")
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 18, height: 18)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .frame(width: 18, height: 18)
                    }
                }
            }.padding()
        }.padding()
            .frame(width: 350)
    }
}

import SwiftUI
import MapKit

struct DetailsView: View {
    @State private var flightNumber: String = ""
    @EnvironmentObject var flightViewModel: FlightViewModel

    func fixTime(dateTime: String?) -> String {
        guard let dateTime = dateTime else { return "N/A" }
        let components = dateTime.split(separator: "T")
        return components.count > 1 ? String(components[1].prefix(5)) : "N/A"
    }

    func fixAirportName(name: String) -> String {
        let words = name.split(separator: " ")
        return words.map { $0 == "International" ? "Intl" : String($0) }.joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if let flight = flightViewModel.flight {
                let airline = flight.airline.name.capitalized
                let flightNo = flight.flightNo.uppercased()
                let status = flight.status.capitalized
                let departureScheduled = fixTime(dateTime: flight.departure.scheduledTime)
                let departureEstimated = fixTime(dateTime: flight.departure.estimatedTime)
                let departureActual = fixTime(dateTime: flight.departure.actualTime)
                let arrivalScheduled = fixTime(dateTime: flight.arrival.scheduledTime)
                let arrivalEstimated = fixTime(dateTime: flight.arrival.estimatedTime)
                let arrivalActual = fixTime(dateTime: flight.arrival.actualTime)

                VStack {
                    Text("\(airline) - \(flightNo)").font(.title2)
                    Text(status).font(.headline)

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

                    if let geography = flight.geography, let speed = flight.speed {
                        VStack {
                            Text("Latitude: \(geography.latitude ?? 0)")
                            Text("Longitude: \(geography.longitude ?? 0)")
                            Text("Altitude: \(geography.altitude ?? 0)m")
                            Text("Horizontal Speed: \(speed.horizontal ?? 0) km/h")
                            Text("Vertical Speed: \(speed.vertical ?? 0) km/h")
                        }.font(.body)
                    } else {
                        Text("No live flight data available").foregroundColor(.gray)
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
                    flightViewModel.fetchFlightDetails(for: flightNumber)
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }.padding()
        }.padding()
    }
}

// Allow to nickname flights and show nickname instead of flight number. e.g. - Juhi's Flight




import SwiftUI

@main
struct FlightBarApp: App {
    @StateObject private var flightViewModel = FlightViewModel()

    var body: some Scene {
        MenuBarExtra {
            DetailsView()
                .environmentObject(flightViewModel)
        } label: {
            Image(systemName: "airplane.circle.fill")
            MenuBarView()
                .environmentObject(flightViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

struct DetailsView: View {
    @EnvironmentObject var flightViewModel: FlightViewModel
    @State private var flightNumber: String = ""

    var body: some View {
        VStack(spacing: 10) {
            if let flight = flightViewModel.flight {
                VStack(alignment: .leading, spacing: 5) {
                    VStack(alignment: .center) {
                        Text("Airline: \(flight.airline.name) \(flight.flight.iata)")
                            .font(.headline)
                        Text("Status: \(flight.flightStatus)")
                            .font(.subheadline)
                    }
                    
                    Divider()
                    
                    Text("Departure")
                        .font(.headline)
                    
                    Text("Airport: \(flight.departure.airport)")
                    Text("Time: \(flight.departure.scheduled ?? "Dep")")
                    
                    Divider()
                    
                    Text("Arrival")
                        .font(.headline)
                    
                    Text("Airport: \(flight.arrival.airport)")
                    Text("Time: \(flight.arrival.scheduled ?? "Arr")")
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
        .onAppear {
            flightNumber = flightViewModel.storedFlightNumber
            flightViewModel.fetchFlightDetails(for: flightNumber)
        }
    }
}

struct MenuBarView: View {
    @EnvironmentObject var flightViewModel: FlightViewModel

    var body: some View {
        if let flight = flightViewModel.flight {
            Text("\(flight.flight.iata) - \(flight.flightStatus)")
        } else {
            Text("Loading Flight Details")
        }
    }
}

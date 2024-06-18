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
            MenuBarView()
                .environmentObject(flightViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

struct DetailsView: View {
    @EnvironmentObject var flightViewModel: FlightViewModel

    var body: some View {
        VStack {
            if let flight = flightViewModel.flight {
                Text("Flight Number: \(flight.flight.iata)")
                Text("ETA: \(flight.arrival.estimated)")
                // Uncomment or adjust these as per the available data
                // Text("Current Speed: \(flight.live?.speedHorizontal ?? 0) km/h")
                // Text("Distance Left: \(flight.arrival.distanceLeft ?? 0) km")
            } else {
                Text("Loading flight details...")
            }
        }
        .padding()
        .onAppear {
            flightViewModel.fetchFlightDetails()
        }
    }
}

struct MenuBarView: View {
    @EnvironmentObject var flightViewModel: FlightViewModel

    var body: some View {
        if let flight = flightViewModel.flight {
            Text("Flight: \(flight.flight.iata), Status: \(flight.flightStatus)")
        } else {
            Text("Click to Reload")
        }
    }
}

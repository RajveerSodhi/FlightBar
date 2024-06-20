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

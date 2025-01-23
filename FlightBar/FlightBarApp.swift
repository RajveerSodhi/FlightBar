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
    
        Settings {
            SettingsView()
        }
    }
}

//
//  AppearanceSettingsView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2025-01-22.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    
    var body: some View {
        Form {
            Toggle("Show Flight Status in Menu Bar", isOn: $settings.showInMenuBar)
                .toggleStyle(.checkbox)
            Toggle("Use Dynamic Icons based on Status", isOn: $settings.showStatusIcons)
                .toggleStyle(.checkbox)
            Toggle("Show Airline Name in Menu Bar", isOn: $settings.showAirline)
                .toggleStyle(.checkbox)
            Toggle("Show Route in Menu Bar", isOn: $settings.showRoute)
                .toggleStyle(.checkbox)
        }
    }
}

#Preview {
    AppearanceSettingsView()
}

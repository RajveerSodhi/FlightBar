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
            Toggle("Show Flight Details in Menu Bar", isOn: $settings.showInMenuBar)
                .toggleStyle(.checkbox)
            Toggle("Use Dynamic Icons based on Status", isOn: $settings.showStatusIcons)
                .toggleStyle(.checkbox)
            Toggle("Show Airline Name in Menu Bar", isOn: $settings.showAirline)
                .toggleStyle(.checkbox)
                .disabled(!settings.showInMenuBar)
            Toggle("Show Route in Menu Bar", isOn: $settings.showRoute)
                .toggleStyle(.checkbox)
                .disabled(!settings.showInMenuBar)
            Toggle("Show Flight No. in Menu Bar", isOn: $settings.showIata)
                .toggleStyle(.checkbox)
                .disabled(!settings.showInMenuBar)
            Toggle("Show Status in Menu Bar", isOn: $settings.showStatus)
                .toggleStyle(.checkbox)
                .disabled(!settings.showInMenuBar)
        }
    }
}

#Preview {
    AppearanceSettingsView()
}

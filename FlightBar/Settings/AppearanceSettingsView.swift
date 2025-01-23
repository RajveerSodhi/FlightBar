//
//  AppearanceSettingsView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2025-01-22.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @State private var showInMenuBar: Bool = false
    @State private var showStatusIcons: Bool = true
    @State private var showAirline: Bool = false
    @State private var showRoute: Bool = false
    
    var body: some View {
        Form {
            Toggle("Show Flight Status in Menu Bar", isOn: $showInMenuBar)
                .toggleStyle(.checkbox)
            Toggle("Use Dynamic Icons based on Status", isOn: $showStatusIcons)
                .toggleStyle(.checkbox)
            Toggle("Show Airline Name in Menu Bar", isOn: $showAirline)
                .toggleStyle(.checkbox)
            Toggle("Show Route in Menu Bar", isOn: $showRoute)
                .toggleStyle(.checkbox)
        }
    }
}

#Preview {
    AppearanceSettingsView()
}

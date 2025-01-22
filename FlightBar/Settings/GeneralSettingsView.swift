//
//  GeneralSettingsView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2025-01-22.
//

import SwiftUI

struct GeneralSettingsView: View {
    @State private var launchAtLogin: Bool = false
    @State private var showDockIcon: Bool = true
    @State private var showNotifications: Bool = false
    @State private var showInMenuBar: Bool = false
    
    var body: some View {
        VStack() {
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .toggleStyle(.checkbox)
            Toggle("Show Dock Icon", isOn: $showDockIcon)
                .toggleStyle(.checkbox)
            Toggle("Show Notification on Flight Status Change", isOn: $showNotifications)
                .toggleStyle(.checkbox)
            Toggle("Show Flight Status in Menu Bar", isOn: $showInMenuBar)
                .toggleStyle(.checkbox)
        }
    }
}

#Preview {
    GeneralSettingsView()
}

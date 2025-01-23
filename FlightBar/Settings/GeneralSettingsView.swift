//
//  GeneralSettingsView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2025-01-22.
//

import SwiftUI
import LaunchAtLogin

struct GeneralSettingsView: View {
    @State private var showDockIcon: Bool = true
    @State private var showNotifications: Bool = false
    
    var body: some View {
        Form {
            LaunchAtLogin.Toggle() {
                Text("Launch at Login")
            }
            Toggle("Show Dock Icon", isOn: $showDockIcon)
                .toggleStyle(.checkbox)
            Toggle("Show Notification on Flight Status Change", isOn: $showNotifications)
                .toggleStyle(.checkbox)
        }
    }
}

#Preview {
    GeneralSettingsView()
}

//
//  GeneralSettingsView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2025-01-22.
//

import SwiftUI
import AppKit
import LaunchAtLogin

struct GeneralSettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    
    func toggleDockIconVisibility(show: Bool) {
        if show {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
    var body: some View {
        Form {
            LaunchAtLogin.Toggle() {
                Text("Launch at Login")
            }
            Toggle("Show Dock Icon", isOn: $settings.showDockIcon)
                .toggleStyle(.checkbox)
            Toggle("Show Notification on Flight Status Change", isOn: $settings.showNotifications)
                .toggleStyle(.checkbox)
        }
    }
}

#Preview {
    GeneralSettingsView()
}

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
    @State private var showDockIcon = UserDefaults.standard.bool(forKey: "ShowDockIcon")
    @State private var showNotifications: Bool = UserDefaults.standard.bool(forKey: "showNotifications")
    
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
            Toggle("Show Dock Icon", isOn: $showDockIcon)
                .toggleStyle(.checkbox)
                .onChange(of: showDockIcon) { oldValue, newValue in
                    toggleDockIconVisibility(show: newValue)
                    UserDefaults.standard.set(newValue, forKey: "ShowDockIcon")
                }
            Toggle("Show Notification on Flight Status Change", isOn: $showNotifications)
                .toggleStyle(.checkbox)
                .onChange(of: showNotifications) { oldValue, newValue in
                    UserDefaults.standard.set(newValue, forKey: "showNotifications")
                }
        }
    }
}

#Preview {
    GeneralSettingsView()
}

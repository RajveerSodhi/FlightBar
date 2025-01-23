//
//  SettingsView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2025-01-22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape.fill")
                }
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "pencil")
                }
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.square.fill")
                }
        }
        .frame(width: 350)
        .padding()
    }
}

#Preview {
    SettingsView()
}

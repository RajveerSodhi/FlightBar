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
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.square.fill")
                }
        }
        .padding()
        .frame(width: 350)
    }
}

#Preview {
    SettingsView()
}

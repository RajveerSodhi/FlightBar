//
//  FlightBarApp.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2024-06-17.
//

import SwiftUI

@main
struct FlightBarApp: App {
    var body: some Scene {
        
        MenuBarExtra {
            DetailsView()
        } label: {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
        
//        WindowGroup {
//            ContentView()
//        }
    }
    
    @ViewBuilder
    func DetailsView() -> some View {
        Image(systemName: "switch.2")
    }
    
    @ViewBuilder
    func MenuBarView() -> some View {
        Image(systemName: "switch.2")
    }
    
}

//
//  MenuBarView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2024-06-18.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var flightViewModel: FlightViewModel
    @ObservedObject var settings = SettingsManager.shared

    var body: some View {
        
        HStack {
            Image("flightbar_menu")
                .resizable()
                .frame(width: 14, height: 14)
            
            if let flight = flightViewModel.flight {
                let status = flight.status.capitalized
                let flightNo = flight.flightNo.uppercased()
                let airline = flight.airline.name.capitalized
                let departureIata = flight.departure.iata
                let arrivalIata = flight.arrival.iata
                let route = "\(departureIata) → \(arrivalIata)"
                let nickname = UserDefaults.standard.string(forKey: "flightNickname") ?? ""
                
                if settings.showInMenuBar {
                    let flightDetails = [
                        settings.showAirline ? airline : nil,
                        settings.showRoute ? route : nil,
                        settings.showIata ? ((settings.useNickname && nickname != "") ? nickname : flightNo) : nil
                    ]
                        .compactMap { $0 }
                        .joined(separator: " | ")
                    
                    let menuText = [
                        flightDetails,
                        settings.showStatus ? status : nil
                    ]
                        .compactMap { $0 }
                        .joined(separator: " - ")
                    
                    Text(menuText)
                }
            } else {
                Text(" Load Flight Details")
            }
        }
    }
}

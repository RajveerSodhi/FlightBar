//
//  MenuBarView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2024-06-18.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var flightViewModel: FlightViewModel

    var body: some View {
        Image("flightbar_menu")
            .resizable()
            .frame(width: 16, height: 16)
            .padding()
        
        if let flight = flightViewModel.flight {
            
            let status = flight.flightStatus.capitalized
            let flightNo = flight.flight.iata.uppercased()
            
            Text("\(flightNo) - \(status)")
        } else {
            Text("Loading Flight Details")
        }
    }
}

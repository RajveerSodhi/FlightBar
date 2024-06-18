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
        if let flight = flightViewModel.flight {
            Text("\(flight.flight.iata) - \(flight.flightStatus)")
        } else {
            Text("Loading Flight Details")
        }
    }
}


#Preview {
    MenuBarView()
}

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
        HStack {
            Image("flightbar_menu")
                .resizable()
                .frame(width: 15, height: 15)

            if let flight = flightViewModel.flight {
                let status = flight.status.capitalized
                let flightNo = flight.flightNo.uppercased()

                Text(" \(flightNo) - \(status)")
            } else {
                Text(" Load Flight Details")
            }
        }
    }
}

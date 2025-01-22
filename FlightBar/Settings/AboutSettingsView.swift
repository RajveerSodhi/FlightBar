//
//  AboutSettingsView.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2025-01-22.
//

import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image("icon")
                    .resizable()
                    .frame(width: 40, height: 40)
                Text("FlightBar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Text("v 2.1.1")
                .font(.subheadline)
                .italic()
                .foregroundColor(.gray)
            
            Divider()
                .padding(.vertical, 10)
            
            Link(destination: URL(string: "https://buymeacoffee.com/rajveersodhi")!) {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(.orange)
                    Text("Support Me")
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(45)
            }
            
            Link(destination: URL(string: "https://www.rajveersodhi.com")!) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                    Text("Visit My Website")
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(45)
            }
            
            Link(destination: URL(string: "mailto:rajveersodhi03@gmail.com")!) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.green)
                    Text("Contact Me")
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(45)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AboutSettingsView()
}

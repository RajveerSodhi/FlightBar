//
//  SettingsManager.swift
//  FlightBar
//
//  Created by Rajveer Sodhi on 2025-01-22.
//

import Foundation
import AppKit

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var showDockIcon: Bool {
        didSet {
            UserDefaults.standard.set(showDockIcon, forKey: "ShowDockIcon")
            NSApp.setActivationPolicy(showDockIcon ? .regular : .accessory)
        }
    }
    
    @Published var showNotifications: Bool {
        didSet {
            UserDefaults.standard.set(showNotifications, forKey: "showNotifications")
        }
    }

    private init() {
        self.showDockIcon = UserDefaults.standard.bool(forKey: "ShowDockIcon")
        self.showNotifications = UserDefaults.standard.bool(forKey: "showNotifications")
    }
}

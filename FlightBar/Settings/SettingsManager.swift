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
    
    @Published var showInMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(showInMenuBar, forKey: "showInMenuBar")
        }
    }
    
    @Published var showStatusIcons: Bool {
        didSet {
            UserDefaults.standard.set(showStatusIcons, forKey: "showStatusIcons")
        }
    }
    
    @Published var showAirline: Bool {
        didSet {
            UserDefaults.standard.set(showAirline, forKey: "showAirline")
        }
    }
    
    @Published var showRoute: Bool {
        didSet {
            UserDefaults.standard.set(showRoute, forKey: "showRoute")
        }
    }

    private init() {
        self.showDockIcon = UserDefaults.standard.bool(forKey: "ShowDockIcon")
        self.showNotifications = UserDefaults.standard.bool(forKey: "showNotifications")
        
        self.showInMenuBar = UserDefaults.standard.bool(forKey: "showInMenuBar")
        self.showStatusIcons = UserDefaults.standard.bool(forKey: "showStatusIcons")
        self.showAirline = UserDefaults.standard.bool(forKey: "showAirline")
        self.showRoute = UserDefaults.standard.bool(forKey: "showRoute")
    }
}


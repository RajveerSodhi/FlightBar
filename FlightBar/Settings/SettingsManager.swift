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
    
    @Published var showIata: Bool {
        didSet {
            UserDefaults.standard.set(showIata, forKey: "showIata")
        }
    }
    
    @Published var showStatus: Bool {
        didSet {
            UserDefaults.standard.set(showStatus, forKey: "showStatus")
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        
        self.showDockIcon = defaults.object(forKey: "ShowDockIcon") as? Bool ?? true
        self.showNotifications = defaults.object(forKey: "showNotifications") as? Bool ?? true
        self.showInMenuBar = defaults.object(forKey: "showInMenuBar") as? Bool ?? true
        self.showStatusIcons = defaults.object(forKey: "showStatusIcons") as? Bool ?? true
        self.showAirline = defaults.object(forKey: "showAirline") as? Bool ?? false
        self.showRoute = defaults.object(forKey: "showRoute") as? Bool ?? false
        self.showIata = defaults.object(forKey: "showIata") as? Bool ?? true
        self.showStatus = defaults.object(forKey: "showStatus") as? Bool ?? true
    }
}


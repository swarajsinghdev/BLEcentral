//
//  AppDelegate.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import UIKit
import BLEKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // One line configuration (log: true to enable BLE event logging; default false)
        BLEManager.configure(serviceUUID: "ABE508FC-CF13-47A4-910F-CC883F9399C6", log: true)
        return true
    }
}

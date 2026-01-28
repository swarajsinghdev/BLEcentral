//
//  BLEcentralApp.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import SwiftUI

@main
struct BLEcentralApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

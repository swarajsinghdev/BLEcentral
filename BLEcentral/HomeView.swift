//
//  HomeView.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import SwiftUI
import CoreBluetooth

struct HomeView: View {
    private let scanner = BLEScanner.shared

    var body: some View {
        NavigationStack {
            VStack {
                Button(scanner.isScanning ? "Stop" : "Scan for My Devices") {
                    scanner.isScanning ? scanner.stopScanning() : scanner.startScanning()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                List(scanner.myDevices) { device in
                    DeviceRow(device: device)
                }
                .overlay {
                    if scanner.myDevices.isEmpty && scanner.isScanning {
                        Text("Searching for your devices...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("My App Beacons")
        }
    }
}

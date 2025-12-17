//
//  HomeView.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Button(viewModel.isScanning ? "Stop" : "Scan for My Devices") {
                    viewModel.isScanning ? viewModel.stopScanning() : viewModel.startScanning()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                List(viewModel.myDevices) { device in
                    DeviceRow(device: device)
                }
                .overlay {
                    if viewModel.myDevices.isEmpty && viewModel.isScanning {
                        Text("Searching for your devices...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("My App Beacons")
        }
    }
}

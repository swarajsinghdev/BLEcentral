//
//  HomeView.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import SwiftUI

/// Main view for displaying and managing BLE device scanning
struct HomeView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let buttonCornerRadius: CGFloat = 8
        static let sectionSpacing: CGFloat = 16
        static let sectionBackgroundOpacity: Double = 0.1
        static let allDevicesBackgroundOpacity: Double = 0.05
        static let sectionPadding: CGFloat = 8
    }
    
    // MARK: - State Properties
    
    @State private var viewModel = HomeViewModel()
    
    // MARK: - Computed Properties
    
    /// Determines if the empty state should be shown
    private var shouldShowEmptyState: Bool {
        viewModel.myDevices.isEmpty && viewModel.isScanning
    }
    
    /// Determines if the initial state should be shown (first time, no devices, not scanning)
    private var shouldShowInitialState: Bool {
        viewModel.latestDevice == nil && viewModel.myDevices.isEmpty && !viewModel.isScanning
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: Constants.sectionSpacing) {
                    if shouldShowInitialState {
                        initialStateView
                    } else {
                        if let latestDevice = viewModel.latestDevice {
                            latestDeviceSection(device: latestDevice)
                        }
                        
                        if !viewModel.myDevices.isEmpty {
                            allDevicesSection
                        }
                        
                        if shouldShowEmptyState {
                            emptyStateView
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Beacons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Refresh button
                        Button(action: {
                            viewModel.refresh()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        
                        // Start/Stop scan button
                        Button(action: {
                            viewModel.isScanning ? viewModel.stopScanning() : viewModel.startScanning()
                        }) {
                            Image(systemName: viewModel.isScanning ? "stop.circle.fill" : "play.circle.fill")
                                .foregroundColor(viewModel.isScanning ? .red : .green)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    /// Latest device section component
    /// 
    /// - Parameter device: The latest discovered device
    /// - Returns: A view displaying the latest device information
    private func latestDeviceSection(device: DeviceInfo) -> some View {
        VStack(alignment: .leading, spacing: Constants.sectionPadding) {
            sectionHeader(title: "Latest Device")
            
            DeviceRow(device: device)
                .padding(.horizontal)
        }
        .background(Color.gray.opacity(Constants.sectionBackgroundOpacity))
        .cornerRadius(Constants.buttonCornerRadius)
        .padding(.horizontal)
    }
    
    /// All devices section component
    private var allDevicesSection: some View {
        VStack(alignment: .leading, spacing: Constants.sectionPadding) {
            sectionHeader(title: "All Devices (\(viewModel.myDevices.count))")
            
            ForEach(viewModel.myDevices) { device in
                DeviceRow(device: device)
                    .padding(.horizontal)
            }
        }
        .background(Color.gray.opacity(Constants.allDevicesBackgroundOpacity))
        .cornerRadius(Constants.buttonCornerRadius)
        .padding(.horizontal)
    }
    
    /// Initial state view when app first runs
    private var initialStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No devices found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the button below to start scanning for BLE devices")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.startScanning()
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Start Scan")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: 200)
                .background(Color.green)
                .cornerRadius(Constants.buttonCornerRadius)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
    }
    
    /// Empty state view when no devices are found
    private var emptyStateView: some View {
        Text("Searching for your devices...")
            .foregroundColor(.secondary)
            .padding()
    }
    
    // MARK: - Helper Methods
    
    /// Creates a section header with consistent styling
    /// 
    /// - Parameter title: The title text for the section
    /// - Returns: A styled text view for section headers
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.horizontal)
            .padding(.top, Constants.sectionPadding)
    }
}

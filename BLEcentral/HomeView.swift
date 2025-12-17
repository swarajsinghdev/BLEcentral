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
    
    /// Button text based on scanning state
    private var scanButtonText: String {
        viewModel.isScanning ? "Stop" : "Scan for My Devices"
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: Constants.sectionSpacing) {
                    scanButton
                    
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
                .padding(.vertical)
            }
            .navigationTitle("My App Beacons")
        }
    }
    
    // MARK: - View Components
    
    /// Scan/Stop button component
    private var scanButton: some View {
        Button(scanButtonText) {
            viewModel.isScanning ? viewModel.stopScanning() : viewModel.startScanning()
        }
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(Constants.buttonCornerRadius)
        .padding(.horizontal)
    }
    
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

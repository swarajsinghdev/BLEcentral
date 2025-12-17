//
//  HomeViewModel.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import Foundation
import Observation

/// ViewModel for HomeView managing Bluetooth service interactions
@Observable
final class HomeViewModel {
    
    // MARK: - Dependencies
    
    /// Bluetooth service for device scanning
    private var bluetoothService: BluetoothServiceProtocol
    
    // MARK: - Observable State
    
    /// Latest discovered device
    var latestDevice: DeviceInfo?
    
    // MARK: - Computed Properties
    
    /// List of discovered BLE devices
    var myDevices: [DeviceInfo] {
        bluetoothService.myDevices
    }
    
    /// Current scanning state
    var isScanning: Bool {
        bluetoothService.isScanning
    }
    
    // MARK: - Initialization
    
    init(bluetoothService: BluetoothServiceProtocol = BluetoothService()) {
        self.bluetoothService = bluetoothService
        
        // Set up latest device notification
        self.bluetoothService.onLatestDevice = { [weak self] deviceInfo in
            self?.handleLatestDevice(deviceInfo)
        }
    }
    
    // MARK: - Private Methods
    
    /// Handles notification when a new device is discovered
    /// 
    /// - Parameter deviceInfo: The latest discovered device information
    private func handleLatestDevice(_ deviceInfo: DeviceInfo) {
        // Update latest device
        latestDevice = deviceInfo
        
        // Print details
        let deviceName = deviceInfo.name ?? deviceInfo.localName ?? "Unknown"
        print("📱 Latest Device Discovered:")
        print("   Name: \(deviceName)")
        print("   ID: \(deviceInfo.identifier.uuidString)")
        print("   RSSI: \(deviceInfo.rssi) dBm")
        print("   Manufacturer Data: \(deviceInfo.manufacturerDataString)")
        print("   Services: \(deviceInfo.serviceUUIDsString)")
        print("---")
    }
    
    // MARK: - Public Methods
    
    /// Starts scanning for BLE devices
    func startScanning() {
        bluetoothService.startScanning()
    }
    
    /// Stops scanning for BLE devices
    func stopScanning() {
        bluetoothService.stopScanning()
    }
}


//
//  HomeViewModel.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import Foundation
import Observation
import BLEKit

/// ViewModel for HomeView managing Bluetooth service interactions.
/// All BLE logging is handled here via BLEManager.onLog and handleLatestDevice.
@Observable
final class HomeViewModel {
    
    // MARK: - Observable State
    
    /// Latest discovered device
    var latestDevice: BLEDevice?
    
    // MARK: - Computed Properties
    
    /// List of discovered BLE devices - one line usage
    var myDevices: [BLEDevice] { BLEManager.devices }
    
    /// Current scanning state
    var isScanning: Bool { BLEManager.isScanning }
    
    // MARK: - Initialization
    
    init() {
        // All BLE logs (state, scan start/stop, status updates) go through here
        BLEManager.onLog = { [weak self] message in
            self?.log(message)
        }
        BLEManager.onDeviceDiscovered { [weak self] device in
            self?.handleLatestDevice(device)
        }
    }
    
    // MARK: - Logging (moved from BLE layer)
    
    private func log(_ message: String) {
        print(message)
    }
    
    /// Handles notification when a new device is discovered
    private func handleLatestDevice(_ device: BLEDevice) {
        latestDevice = device
        let name = device.name ?? device.localName ?? "Unknown"
        log("📱 Latest Device Discovered:")
        log("   Name: \(name)")
        log("   ID: \(device.identifier.uuidString)")
        log("   RSSI: \(device.rssi) dBm")
        log("   Manufacturer Data: \(device.manufacturerDataString)")
        log("   Services: \(device.serviceUUIDsString)")
        log("---")
    }
    
    // MARK: - Public Methods
    
    /// Starts scanning for BLE devices - one line usage
    func startScanning() {
        BLEManager.start()
    }
    
    /// Stops scanning for BLE devices - one line usage
    func stopScanning() {
        BLEManager.stop()
    }
    
    /// Refreshes the device list by stopping and restarting scan
    func refresh() {
        if isScanning {
            stopScanning()
        }
        // Clear latest device
        latestDevice = nil
        // Restart scanning after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startScanning()
        }
    }
}


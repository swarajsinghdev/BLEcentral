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
    let bluetoothService: BluetoothService
    
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
    
    init(bluetoothService: BluetoothService = BluetoothService.shared) {
        self.bluetoothService = bluetoothService
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


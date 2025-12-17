//
//  BluetoothServiceProtocol.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import Foundation

/// Protocol defining the interface for Bluetooth Low Energy scanning services
protocol BluetoothServiceProtocol {
    /// List of discovered BLE devices
    var myDevices: [DeviceInfo] { get }
    
    /// Current scanning state
    var isScanning: Bool { get }
    
    /// Enable or disable logging output
    var isLoggingEnabled: Bool { get set }
    
    /// Starts scanning for BLE devices
    func startScanning()
    
    /// Stops scanning for BLE devices
    func stopScanning()
}


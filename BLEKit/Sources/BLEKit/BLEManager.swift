//
//  BLEManager.swift
//  BLEKit
//
//  Copyright (c) 2026 BLEKit. All rights reserved.
//
//  Public API for BLE central scanning (configure, start, stop, devices).
//

import Foundation
import CoreBluetooth

public class BLEManager {
    
    private static let shared = BluetoothService.shared
    
    private static var config: BLEConfiguration?
    
    /// - Parameters:
    ///   - serviceUUID: Service UUID to scan for
    ///   - namePrefix: Optional name prefix to filter devices (omit to accept all)
    ///   - log: Enable BLE event logging (default false)
    public static func configure(serviceUUID: String, namePrefix: String? = nil, log: Bool = false) {
        config = BLEConfiguration(serviceUUID: serviceUUID, namePrefix: namePrefix ?? "")
        BluetoothService.shared.setConfiguration(config!)
        BluetoothService.shared.isLoggingEnabled = log
    }
    
    public static var devices: [BLEDevice] {
        shared.myDevices
    }
    
    public static func start() { shared.startScanning() }
    public static func stop() { shared.stopScanning() }
    
    public static var isScanning: Bool { shared.isScanning }
    
    public static func onDeviceDiscovered(_ callback: @escaping (BLEDevice) -> Void) {
        shared.onLatestDevice = callback
    }
    
    /// Optional log callback – set from app (e.g. HomeViewModel) to receive BLE events
    public static var onLog: ((String) -> Void)? {
        get { shared.onLog }
        set { shared.onLog = newValue }
    }
}

struct BLEConfiguration {
    let serviceUUID: CBUUID
    let namePrefix: String
    
    init(serviceUUID: String, namePrefix: String = "") {
        self.serviceUUID = CBUUID(string: serviceUUID)
        self.namePrefix = namePrefix
    }
}

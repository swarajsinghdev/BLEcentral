//
//  BluetoothServiceProtocol.swift
//  BLEKit
//
//  Copyright (c) 2026 BLEKit. All rights reserved.
//
//  Protocol for the BLE scanning service interface.
//

import Foundation

protocol BluetoothServiceProtocol {
    var myDevices: [BLEDevice] { get }
    var isScanning: Bool { get }
    var isLoggingEnabled: Bool { get set }
    var onLatestDevice: ((BLEDevice) -> Void)? { get set }
    var onLog: ((String) -> Void)? { get set }
    func startScanning()
    func stopScanning()
}

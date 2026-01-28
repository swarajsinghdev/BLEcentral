//
//  BluetoothService.swift
//  BLEKit
//
//  Copyright (c) 2026 BLEKit. All rights reserved.
//
//  Core Bluetooth central manager: scanning, discovery, and device list.
//

import Foundation
import CoreBluetooth
import Observation

@Observable
final class BluetoothService: NSObject, BluetoothServiceProtocol, CBCentralManagerDelegate {
    
    private enum Constants {
        static let statusUpdateInterval: TimeInterval = 60.0
    }
    
    static let shared = BluetoothService()
    
    private var config: BLEConfiguration?
    
    func setConfiguration(_ config: BLEConfiguration) {
        self.config = config
    }
    
    private var central: CBCentralManager!
    
    var myDevices: [BLEDevice] = []
    var isScanning = false
    var isLoggingEnabled = false
    
    private var statusTimer: Timer?
    private var deviceMap: [UUID: Int] = [:]
    
    var onLatestDevice: ((BLEDevice) -> Void)?
    var onLog: ((String) -> Void)?
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    deinit {
        stopStatusTimer()
        central.stopScan()
    }
    
    func startScanning() {
        guard central.state == .poweredOn else {
            report("❌ Cannot start scanning: Bluetooth is not powered on")
            return
        }
        
        guard let config = config else {
            report("❌ Cannot start scanning: Configuration not set. Call BLEManager.configure() in AppDelegate")
            return
        }
        
        report("✅ START SCANNING")
        clearDevices()
        isScanning = true
        
        central.scanForPeripherals(
            withServices: [config.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        
        startStatusTimer()
    }
    
    func stopScanning() {
        report("🛑 STOP SCANNING")
        central.stopScan()
        isScanning = false
        stopStatusTimer()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            report("✅ Bluetooth powered on")
        case .poweredOff:
            report("⚠️ Bluetooth powered off")
        case .unauthorized:
            report("⚠️ Bluetooth unauthorized")
        case .unsupported:
            report("⚠️ Bluetooth unsupported")
        case .resetting:
            report("⚠️ Bluetooth resetting")
        case .unknown:
            report("⚠️ Bluetooth state unknown")
        @unknown default:
            report("⚠️ Bluetooth state: \(bluetoothStateString(central.state))")
        }
        
        if central.state != .poweredOn && isScanning {
            stopScanning()
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        handleDiscoveredDevice(peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    private func clearDevices() {
        deviceMap.removeAll()
        myDevices.removeAll()
    }
    
    private func handleDiscoveredDevice(
        _ peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        guard let config = config else { return }
        
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let advertisedName = peripheral.name ?? localName
        
        guard let name = advertisedName, name.hasPrefix(config.namePrefix) else {
            return
        }
        
        let identifier = peripheral.identifier
        let bleDevice = BLEDevice(
            peripheral: peripheral,
            advertisementData: advertisementData,
            rssi: rssi
        )
        
        if let existingIndex = deviceMap[identifier] {
            myDevices[existingIndex] = bleDevice
        } else {
            let newIndex = myDevices.count
            myDevices.append(bleDevice)
            deviceMap[identifier] = newIndex
        }
        
        onLatestDevice?(bleDevice)
    }
    
    private func report(_ message: String) {
        guard isLoggingEnabled else { return }
        onLog?(message)
    }
    
    private func startStatusTimer() {
        stopStatusTimer()
        statusTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.statusUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.reportStatus()
        }
    }
    
    private func stopStatusTimer() {
        statusTimer?.invalidate()
        statusTimer = nil
    }
    
    private func reportStatus() {
        report("\n📊 === STATUS UPDATE (Every 1 min) ===")
        report("Scanning: \(isScanning ? "YES" : "NO")")
        report("Bluetooth State: \(bluetoothStateString(central.state))")
        report("Devices Found: \(myDevices.count)")
        
        if myDevices.isEmpty {
            report("No devices found yet.")
        } else {
            report("\n📱 Discovered Devices:")
            for (index, device) in myDevices.enumerated() {
                let deviceName = device.name ?? device.localName ?? "Unknown"
                report("  [\(index + 1)] \(deviceName)")
                report("      ID: \(device.identifier.uuidString)")
                report("      RSSI: \(device.rssi) dBm")
                report("      Manufacturer Data: \(device.manufacturerDataString)")
            }
        }
        report("=====================================\n")
    }
    
    private func bluetoothStateString(_ state: CBManagerState) -> String {
        switch state {
        case .unknown: return "Unknown"
        case .resetting: return "Resetting"
        case .unsupported: return "Unsupported"
        case .unauthorized: return "Unauthorized"
        case .poweredOff: return "Powered Off"
        case .poweredOn: return "Powered On"
        @unknown default: return "Unknown State"
        }
    }
}

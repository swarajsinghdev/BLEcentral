//
//  BLEScanner.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import Foundation
import CoreBluetooth
import Combine

class BLEScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    static let shared = BLEScanner()

    private var central: CBCentralManager!
    @Published var myDevices: [DeviceInfo] = []  // Only your devices
    @Published var isScanning = false
    
    private var statusTimer: Timer?

    // === CHANGE THESE TO MATCH YOUR PERIPHERAL ===
    private let myServiceUUID = CBUUID(string: "ABE508FC-CF13-47A4-910F-CC883F9399C6")
    private let namePrefix = "SB-"  // Alternative: if devices advertise name like "MyApp-Beacon1"
    // private let customMarker = "MYAPP2025"  // If in manufacturer data

    private override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard central.state == .poweredOn else {
            print("❌ Cannot start scanning: Bluetooth is not powered on")
            return
        }
        
        print("✅ START SCANNING")
        myDevices.removeAll()
        isScanning = true

        // BEST: Filter by service UUID → ignores 95% of devices early
        central.scanForPeripherals(withServices: [myServiceUUID],
                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])

        // If no service UUID, use nil and filter below
        // central.scanForPeripherals(withServices: nil, ...)
        
        // Start status timer (prints every 1 minute)
        startStatusTimer()
    }

    func stopScanning() {
        print("🛑 STOP SCANNING")
        central.stopScan()
        isScanning = false
        stopStatusTimer()
    }

    // MARK: - Status Timer
    private func startStatusTimer() {
        stopStatusTimer() // Make sure no existing timer
        
        statusTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.printStatus()
        }
    }
    
    private func stopStatusTimer() {
        statusTimer?.invalidate()
        statusTimer = nil
    }
    
    private func printStatus() {
        print("\n📊 === STATUS UPDATE (Every 1 min) ===")
        print("Scanning: \(isScanning ? "YES" : "NO")")
        print("Bluetooth State: \(bluetoothStateString(central.state))")
        print("Devices Found: \(myDevices.count)")
        
        if !myDevices.isEmpty {
            print("\n📱 Discovered Devices:")
            for (index, device) in myDevices.enumerated() {
                print("  [\(index + 1)] \(device.name ?? device.localName ?? "Unknown")")
                print("      ID: \(device.identifier.uuidString)")
                print("      RSSI: \(device.rssi) dBm")
                print("      Manufacturer Data: \(device.manufacturerDataString)")
            }
        } else {
            print("No devices found yet.")
        }
        print("=====================================\n")
    }
    
    private func bluetoothStateString(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "Unknown"
        case .resetting:
            return "Resetting"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "Powered Off"
        case .poweredOn:
            return "Powered On"
        @unknown default:
            return "Unknown State"
        }
    }
    
    // MARK: - Delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("⚠️ Bluetooth off")
        } else {
            print("✅ Bluetooth powered on")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {

        // PRINT FULL DETAILS FOR DEBUGGING
        print("=== Discovered ===")
        print("Name: \(peripheral.name ?? "nil")")
        print("Local Name: \(advertisementData[CBAdvertisementDataLocalNameKey] ?? "nil")")
        print("Manufacturer Data: \(advertisementData[CBAdvertisementDataManufacturerDataKey] ?? "nil")")
        print("Services: \(advertisementData[CBAdvertisementDataServiceUUIDsKey] ?? "nil")")
        print("ID: \(peripheral.identifier)")
        print("RSSI: \(RSSI) dBm\n")

        // FILTER: Only add YOUR devices
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let advertisedName = peripheral.name ?? localName

        // Option 1: If scanning with service UUID → auto-filtered, just add
        // Option 2: Name-based filter
       // guard advertisedName?.hasPrefix(namePrefix) == true else { return }

        // Option 3: Custom string in manufacturer data
        // if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
        //    let string = String(data: data, encoding: .utf8),
        //    string.contains(customMarker) { } else { return }

        // Avoid duplicates
        if !myDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            let deviceInfo = DeviceInfo(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
            myDevices.append(deviceInfo)
        } else {
            // Update existing device with latest RSSI and advertisement data
            if let index = myDevices.firstIndex(where: { $0.identifier == peripheral.identifier }) {
                let deviceInfo = DeviceInfo(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
                myDevices[index] = deviceInfo
            }
        }
    }
}

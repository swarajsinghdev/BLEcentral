//
//  BLEScanner.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import Foundation
import CoreBluetooth
import Combine

/// Manages Bluetooth Low Energy device scanning and discovery
/// 
/// This class handles scanning for BLE peripherals, filtering discovered devices,
/// and maintaining a list of discovered devices. It uses CoreBluetooth's CBCentralManager
/// to scan for peripherals matching specific criteria.
class BLEScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    
    // MARK: - Constants
    
    /// Service UUID to filter devices during scanning
    private enum Constants {
        /// Service UUID for target peripherals
        static let serviceUUID = CBUUID(string: "ABE508FC-CF13-47A4-910F-CC883F9399C6")
        
        /// Name prefix for filtering devices (optional)
        static let namePrefix = "SB-"
        
        /// Status update interval in seconds
        static let statusUpdateInterval: TimeInterval = 60.0
    }
    
    // MARK: - Singleton
    
    static let shared = BLEScanner()
    
    // MARK: - Dependencies
    
    /// Core Bluetooth central manager for scanning
    private var central: CBCentralManager!
    
    // MARK: - Published State
    
    /// List of discovered BLE devices
    @Published var myDevices: [DeviceInfo] = []
    
    /// Current scanning state
    @Published var isScanning = false
    
    // MARK: - Private Properties
    
    /// Timer for periodic status updates
    private var statusTimer: Timer?
    
    /// Dictionary for efficient device lookup by identifier
    private var deviceMap: [UUID: Int] = [:]
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
    deinit {
        stopStatusTimer()
        central.stopScan()
    }
    
    // MARK: - Public API Methods
    
    /// Starts scanning for BLE devices
    /// 
    /// This method initiates scanning for peripherals matching the configured service UUID.
    /// It clears existing devices and starts a status update timer.
    /// 
    /// - Note: Scanning will only start if Bluetooth is powered on
    func startScanning() {
        guard central.state == .poweredOn else {
            print("❌ Cannot start scanning: Bluetooth is not powered on")
            return
        }
        
        print("✅ START SCANNING")
        clearDevices()
        isScanning = true
        
        // Filter by service UUID for efficient scanning
        central.scanForPeripherals(
            withServices: [Constants.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        
        startStatusTimer()
    }
    
    /// Stops scanning for BLE devices
    /// 
    /// This method stops the central manager from scanning and invalidates
    /// the status update timer.
    func stopScanning() {
        print("🛑 STOP SCANNING")
        central.stopScan()
        isScanning = false
        stopStatusTimer()
    }
    
    // MARK: - CBCentralManagerDelegate
    
    /// Called when the central manager's state changes
    /// - Parameter central: The central manager whose state changed
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let stateString = bluetoothStateString(central.state)
        
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth powered on")
        case .poweredOff:
            print("⚠️ Bluetooth powered off")
        case .unauthorized:
            print("⚠️ Bluetooth unauthorized")
        case .unsupported:
            print("⚠️ Bluetooth unsupported")
        case .resetting:
            print("⚠️ Bluetooth resetting")
        case .unknown:
            print("⚠️ Bluetooth state unknown")
        @unknown default:
            print("⚠️ Bluetooth state: \(stateString)")
        }
        
        // Stop scanning if Bluetooth is not available
        if central.state != .poweredOn && isScanning {
            stopScanning()
        }
    }
    
    /// Called when a peripheral is discovered during scanning
    /// 
    /// - Parameters:
    ///   - central: The central manager providing the update
    ///   - peripheral: The discovered peripheral
    ///   - advertisementData: Dictionary containing advertisement data
    ///   - rssi: Received signal strength indicator
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        logDiscoveredDevice(peripheral, advertisementData: advertisementData, rssi: RSSI)
        handleDiscoveredDevice(peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    // MARK: - Private Methods - Device Management
    
    /// Clears all discovered devices and resets the device map
    private func clearDevices() {
        deviceMap.removeAll()
        myDevices.removeAll()
    }
    
    /// Handles a newly discovered peripheral device
    /// 
    /// - Parameters:
    ///   - peripheral: The discovered peripheral
    ///   - advertisementData: Advertisement data from the peripheral
    ///   - rssi: Signal strength
    private func handleDiscoveredDevice(
        _ peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        let identifier = peripheral.identifier
        let deviceInfo = DeviceInfo(
            peripheral: peripheral,
            advertisementData: advertisementData,
            rssi: rssi
        )
        
        // Use dictionary for O(1) lookup instead of O(n) array search
        if let existingIndex = deviceMap[identifier] {
            // Update existing device
            myDevices[existingIndex] = deviceInfo
        } else {
            // Add new device
            let newIndex = myDevices.count
            myDevices.append(deviceInfo)
            deviceMap[identifier] = newIndex
        }
    }
    
    // MARK: - Private Methods - Logging
    
    /// Logs detailed information about a discovered device
    /// 
    /// - Parameters:
    ///   - peripheral: The discovered peripheral
    ///   - advertisementData: Advertisement data
    ///   - rssi: Signal strength
    private func logDiscoveredDevice(
        _ peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        print("=== Discovered ===")
        print("Name: \(peripheral.name ?? "nil")")
        print("Local Name: \(advertisementData[CBAdvertisementDataLocalNameKey] ?? "nil")")
        print("Manufacturer Data: \(advertisementData[CBAdvertisementDataManufacturerDataKey] ?? "nil")")
        print("Services: \(advertisementData[CBAdvertisementDataServiceUUIDsKey] ?? "nil")")
        print("ID: \(peripheral.identifier)")
        print("RSSI: \(rssi) dBm\n")
    }
    
    // MARK: - Private Methods - Status Timer
    
    /// Starts the status update timer
    /// 
    /// The timer fires every minute to print current scanning status
    private func startStatusTimer() {
        stopStatusTimer()
        
        statusTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.statusUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.printStatus()
        }
    }
    
    /// Stops and invalidates the status update timer
    private func stopStatusTimer() {
        statusTimer?.invalidate()
        statusTimer = nil
    }
    
    /// Prints current scanning status and discovered devices
    /// 
    /// This method is called periodically by the status timer to provide
    /// updates on the scanning progress and discovered devices.
    private func printStatus() {
        print("\n📊 === STATUS UPDATE (Every 1 min) ===")
        print("Scanning: \(isScanning ? "YES" : "NO")")
        print("Bluetooth State: \(bluetoothStateString(central.state))")
        print("Devices Found: \(myDevices.count)")
        
        if myDevices.isEmpty {
            print("No devices found yet.")
        } else {
            print("\n📱 Discovered Devices:")
            for (index, device) in myDevices.enumerated() {
                let deviceName = device.name ?? device.localName ?? "Unknown"
                print("  [\(index + 1)] \(deviceName)")
                print("      ID: \(device.identifier.uuidString)")
                print("      RSSI: \(device.rssi) dBm")
                print("      Manufacturer Data: \(device.manufacturerDataString)")
            }
        }
        print("=====================================\n")
    }
    
    // MARK: - Private Methods - Helpers
    
    /// Returns a human-readable string for Bluetooth manager state
    /// 
    /// - Parameter state: The Bluetooth manager state
    /// - Returns: A descriptive string for the state
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
}

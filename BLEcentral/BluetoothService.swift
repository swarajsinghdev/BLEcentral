//
//  BluetoothService.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import Foundation
import CoreBluetooth
import Observation

/// Manages Bluetooth Low Energy device scanning and discovery
/// 
/// This class handles scanning for BLE peripherals, filtering discovered devices,
/// and maintaining a list of discovered devices. It uses CoreBluetooth's CBCentralManager
/// to scan for peripherals matching specific criteria.
@Observable
final class BluetoothService: NSObject, BluetoothServiceProtocol, CBCentralManagerDelegate {
    
    // MARK: - Constants
    
    /// Service UUID to filter devices during scanning
    private enum Constants {
        /// Service UUID for target peripherals
        static let serviceUUID = CBUUID(string: "ABE508FC-CF13-47A4-910F-CC883F9399C6")
        
        /// Name prefix for filtering devices (optional)
        static let namePrefix = "000"//"SB-"
        
        /// Status update interval in seconds
        static let statusUpdateInterval: TimeInterval = 60.0
    }
    
    // MARK: - Dependencies
    
    /// Core Bluetooth central manager for scanning
    private var central: CBCentralManager!
    
    // MARK: - Observable State
    
    /// List of discovered BLE devices
    var myDevices: [DeviceInfo] = []
    
    /// Current scanning state
    var isScanning = false
    
    // MARK: - Private Properties
    
    /// Timer for periodic status updates
    private var statusTimer: Timer?
    
    /// Dictionary for efficient device lookup by identifier
    private var deviceMap: [UUID: Int] = [:]
    
    /// Enable or disable logging output
    var isLoggingEnabled: Bool = true
    
    // MARK: - Initialization
    
    override init() {
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
            log("❌ Cannot start scanning: Bluetooth is not powered on")
            return
        }
        
        log("✅ START SCANNING")
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
        log("🛑 STOP SCANNING")
        central.stopScan()
        isScanning = false
        stopStatusTimer()
    }
    
    // MARK: - CBCentralManagerDelegate
    
    /// Called when the central manager's state changes
    /// - Parameter central: The central manager whose state changed
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            log("✅ Bluetooth powered on")
        case .poweredOff:
            log("⚠️ Bluetooth powered off")
        case .unauthorized:
            log("⚠️ Bluetooth unauthorized")
        case .unsupported:
            log("⚠️ Bluetooth unsupported")
        case .resetting:
            log("⚠️ Bluetooth resetting")
        case .unknown:
            log("⚠️ Bluetooth state unknown")
        @unknown default:
            log("⚠️ Bluetooth state: \(bluetoothStateString(central.state))")
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
        // Filter by name prefix if configured
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let advertisedName = peripheral.name ?? localName
        
        // Only process devices matching the name prefix
        guard let name = advertisedName, name.hasPrefix(Constants.namePrefix) else {
            return
        }
        
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
    
    /// Centralized logging function
    /// 
    /// Prints the message only if logging is enabled
    /// 
    /// - Parameter message: The message to log
    private func log(_ message: String) {
        guard isLoggingEnabled else { return }
        print(message)
    }
    
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
        log("=== Discovered ===")
        log("Name: \(peripheral.name ?? "nil")")
        log("Local Name: \(advertisementData[CBAdvertisementDataLocalNameKey] ?? "nil")")
        log("Manufacturer Data: \(advertisementData[CBAdvertisementDataManufacturerDataKey] ?? "nil")")
        log("Services: \(advertisementData[CBAdvertisementDataServiceUUIDsKey] ?? "nil")")
        log("ID: \(peripheral.identifier)")
        log("RSSI: \(rssi) dBm\n")
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
        log("\n📊 === STATUS UPDATE (Every 1 min) ===")
        log("Scanning: \(isScanning ? "YES" : "NO")")
        log("Bluetooth State: \(bluetoothStateString(central.state))")
        log("Devices Found: \(myDevices.count)")
        
        if myDevices.isEmpty {
            log("No devices found yet.")
        } else {
            log("\n📱 Discovered Devices:")
            for (index, device) in myDevices.enumerated() {
                let deviceName = device.name ?? device.localName ?? "Unknown"
                log("  [\(index + 1)] \(deviceName)")
                log("      ID: \(device.identifier.uuidString)")
                log("      RSSI: \(device.rssi) dBm")
                log("      Manufacturer Data: \(device.manufacturerDataString)")
            }
        }
        log("=====================================\n")
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

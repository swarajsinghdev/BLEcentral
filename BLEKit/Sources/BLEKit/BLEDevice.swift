//
//  BLEDevice.swift
//  BLEKit
//
//  Copyright (c) 2026 BLEKit. All rights reserved.
//
//  Model for a discovered BLE peripheral and its advertisement data.
//

import Foundation
import CoreBluetooth

public struct BLEDevice: Identifiable {
    public let id: UUID
    public let peripheral: CBPeripheral
    public let name: String?
    public let localName: String?
    public let manufacturerData: Data?
    public let serviceUUIDs: [CBUUID]?
    public let rssi: Int
    public let identifier: UUID
    public let advertisementData: [String: Any]
    
    public init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.id = peripheral.identifier
        self.identifier = peripheral.identifier
        self.name = peripheral.name
        self.localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        self.manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        self.serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
        self.rssi = rssi.intValue
        self.advertisementData = advertisementData
    }
    
    public var manufacturerDataString: String {
        guard let data = manufacturerData else {
            return "data is nil"
        }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    public var serviceUUIDsString: String {
        guard let uuids = serviceUUIDs, !uuids.isEmpty else {
            return "data is nil"
        }
        return uuids.map { $0.uuidString }.joined(separator: ", ")
    }
}

//
//  DeviceInfo.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import Foundation
import CoreBluetooth

struct DeviceInfo: Identifiable {
    let id: UUID
    let peripheral: CBPeripheral
    let name: String?
    let localName: String?
    let manufacturerData: Data?
    let serviceUUIDs: [CBUUID]?
    let rssi: Int
    let identifier: UUID
    let advertisementData: [String: Any]
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
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
    
    var manufacturerDataString: String {
        guard let data = manufacturerData else {
            return "data is nil"
        }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    var serviceUUIDsString: String {
        guard let uuids = serviceUUIDs, !uuids.isEmpty else {
            return "data is nil"
        }
        return uuids.map { $0.uuidString }.joined(separator: ", ")
    }
}


//
//  DeviceRow.swift
//  BLEcentral
//
//  Created by Swarajmeet Singh on 15/12/25.
//

import SwiftUI
import CoreBluetooth

struct DeviceRow: View {
    let device: DeviceInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with name and RSSI
            HStack {
                Text(device.name ?? device.localName ?? "Unknown Device")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(device.rssi) dBm")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Divider()
            
            // Device ID
            InfoRow(label: "ID", value: device.identifier.uuidString)
            
            // Name
            if let name = device.name {
                InfoRow(label: "Name", value: name)
            }
            
            // Local Name
            if let localName = device.localName {
                InfoRow(label: "Local Name", value: localName)
            }
            
            // Manufacturer Data
            InfoRow(label: "Manufacturer Data", value: device.manufacturerDataString)
            
            // Service UUIDs
            InfoRow(label: "Services", value: device.serviceUUIDsString)
        }
        .padding(.vertical, 8)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(label):")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}


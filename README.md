# BLEcentral

Simple SwiftUI app for scanning Bluetooth Low Energy (BLE) peripherals and
displaying discovered devices in a clean list UI.

## Overview

BLEcentral uses CoreBluetooth to scan for peripherals advertising a specific
service UUID and (optionally) a name prefix. Discovered devices are shown in
two sections: the most recently discovered device and a list of all devices.

## Features

- Start/stop BLE scanning from the toolbar or initial empty state.
- Filters devices by service UUID and name prefix.
- Shows latest discovered device details.
- Lists all devices with RSSI, identifiers, and advertising data.
- Periodic status logging while scanning (every 60 seconds).

## Requirements

- Xcode 26.1+
- iOS 17.6+ (target setting in the project)
- A physical iOS device with Bluetooth enabled (simulator cannot scan BLE)

## Permissions

This app requests Bluetooth scanning permissions via Info.plist settings in
the Xcode project:

- `NSBluetoothAlwaysUsageDescription`: "Scanning for BLE devices"

## Project Structure

- `BLEcentral/BLEcentralApp.swift`: App entry point.
- `BLEcentral/HomeView.swift`: Main UI with scanning controls and device lists.
- `BLEcentral/HomeViewModel.swift`: View model that manages scanning state and
  latest device updates.
- `BLEcentral/DeviceRow.swift`: UI row for showing device details.
- `BLEcentral/Bluetooth/`
  - `BLEManager.swift`: Public API (configure, start, stop, devices).
  - `BluetoothService.swift`: CoreBluetooth scanning service.
  - `BluetoothServiceProtocol.swift`: Protocol for the service.
  - `BLEDevice.swift`: Model for discovered device data.
- `BLEcentral/Assets.xcassets/`: App icons and colors.

## How It Works

- `BluetoothService` manages a `CBCentralManager` and scans for peripherals
  advertising a configured service UUID.
- Devices are filtered by a name prefix before being displayed.
- The latest discovered device is surfaced via a callback to the view model.

## Configuration

Configure in AppDelegate with `BLEManager.configure(serviceUUID:namePrefix:)`:

- Service UUID (required): e.g. `"ABE508FC-CF13-47A4-910F-CC883F9399C6"`
- Name prefix (optional): e.g. `"000"` to filter by name; omit to accept all devices

## Running the App

1. Open `BLEcentral.xcodeproj` in Xcode.
2. Select a physical iOS device target.
3. Build and run.
4. Tap the play button to start scanning.

## Notes

- If Bluetooth is powered off or unavailable, scanning will not start.
- Scanning stops automatically if the Bluetooth state becomes unavailable.

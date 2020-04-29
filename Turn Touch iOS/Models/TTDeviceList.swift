//
//  TTDeviceList.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation
import CoreBluetooth

class TTDeviceList: NSObject {
    
    var peripherals: [CBPeripheral] = []
    var devices: [TTDevice] = []
    
    override init() {
        super.init()
    }
    
    override var description : String {
        var peripheralIds: [String] = []
        for device: TTDevice in devices {
            peripheralIds.append(device.description)
        }
        return peripheralIds.joined(separator: ", ")
    }
    
    func deviceForPeripheral(_ peripheral: CBPeripheral) -> TTDevice? {
        for device: TTDevice in devices {
            if device.peripheral == nil {
                continue
            }
            if device.peripheral == peripheral {
                return device
            }
        }
        return nil
    }
    
    func peripheralForDevice(_ device: TTDevice) -> CBPeripheral? {
        for foundDevice: TTDevice in devices {
            if foundDevice.peripheral == nil {
                continue
            }
            if foundDevice.uuid == device.uuid {
                return foundDevice.peripheral
            }
        }
        return nil
    }
    
    func objectAtIndex(_ index: Int) -> TTDevice {
        return devices[index]
    }
    
    // MARK: Devices
    
    func addPeripheral(_ peripheral: CBPeripheral) -> TTDevice {
        let device = TTDevice(peripheral: peripheral)
        
        self.addDevice(device)

        return device
    }
    
    func addDevice(_ device: TTDevice) {
        var addDevice = device
        addDevice.isPaired = self.isDevicePaired(addDevice)
        
        for foundDevice in devices {
            if foundDevice.peripheral == nil {
                continue
            }
            if foundDevice.peripheral.identifier.uuidString == addDevice.peripheral.identifier.uuidString {
                print(" ---> Already added device: \(foundDevice) - \(addDevice)")
                addDevice = foundDevice
            }
        }
        
        if !devices.contains(addDevice) {
            devices.append(addDevice)
        } else {
            print(" ---> Already added device and not adding again: \(addDevice)")
        }
        
        addDevice.state = .device_STATE_DISCONNECTED
    }

    func removePeripheral(_ peripheral: CBPeripheral) {
        let device: TTDevice? = self.deviceForPeripheral(peripheral)
        if device != nil {
            self.removeDevice(device!)
        }
    }
    
    func removeDevice(_ device: TTDevice) {
        let removeDevice: TTDevice? = device
        var updatedDevices: [TTDevice] = []
        for foundDevice: TTDevice in devices {
            if foundDevice.uuid != removeDevice?.uuid {
                updatedDevices.append(foundDevice)
            } else {
                // Don't null out the peripheral since you need to keep a reference
//                foundDevice.peripheral.delegate = nil
//                foundDevice.peripheral = nil
                foundDevice.state = .device_STATE_DISCONNECTED
            }
        }
        
        devices = updatedDevices
    }
    
    func ensureDevicesConnected() {
        var updatedConnectedDevices: [TTDevice] = []
        
        for device: TTDevice in devices {
            if device.state == .device_STATE_CONNECTED && device.peripheral.state == .disconnected {
                device.peripheral.delegate = nil
                device.peripheral = nil
//                device.isPaired = self.isDevicePaired(device)
            } else {
                updatedConnectedDevices.append(device)
            }
        }
        
        devices = updatedConnectedDevices
    }
    
    func connectedDeviceAtIndex(_ index: Int) -> TTDevice? {
        var i = 0
        for device: TTDevice in devices {
            if device.connected() {
                if i == index {
                    return device
                }
                i += 1
            }
        }
        
        return nil
    }
    
    // MARK: Pairing
    
    func isPeripheralPaired(_ peripheral: CBPeripheral) -> Bool {
        let prefs = preferences()
        let pairedDevices = prefs.array(forKey: "TT:devices:paired") as! [String]?
        
        if pairedDevices == nil {
            return false
        }
        
        return pairedDevices!.contains(peripheral.identifier.uuidString)
    }
    
    func isDevicePaired(_ device: TTDevice) -> Bool {
        return self.isPeripheralPaired(device.peripheral)
    }
    
    // MARK: Counting
    
    func count() -> Int {
        return devices.count
    }
    
    func connectedCount() -> Int {
        var count = 0
        for device: TTDevice in devices {
            if device.connected() {
                count += 1
            }
        }
        
        return count
    }
    
    func totalPairedCount() -> Int {
        let prefs = preferences()
        let pairedDevices = prefs.array(forKey: "TT:devices:paired") as! [String]?
        
        if pairedDevices == nil {
            return 0
        }

        return pairedDevices!.count
    }
    
    func connected() -> [TTDevice] {
        return devices.filter { (device) in
            device.peripheral != nil && device.state == TTDeviceState.device_STATE_CONNECTED
        }
    }
    
    func pairedConnected() -> [TTDevice] {
        return devices.filter { (device) in
            device.peripheral != nil && self.isPeripheralPaired(device.peripheral) && device.state == TTDeviceState.device_STATE_CONNECTED
        }
    }
    
    func nicknamedConnected() -> [TTDevice] {
        return self.pairedConnected().filter { (device) in
            device.nickname != nil
        }
    }
    
    func unpairedConnected() -> [TTDevice] {
        return devices.filter({ (device) -> Bool in
            device.peripheral != nil && !self.isPeripheralPaired(device.peripheral) && device.state == .device_STATE_CONNECTED
        })
    }
    func unpairedConnecting() -> [TTDevice] {
        return devices.filter({ (device) -> Bool in
            device.peripheral != nil && !self.isPeripheralPaired(device.peripheral) && device.state == .device_STATE_CONNECTING
        })
    }
    
}

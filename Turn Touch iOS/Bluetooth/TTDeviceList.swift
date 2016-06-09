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
        return peripheralIds.joinWithSeparator(", ")
    }
    
    func deviceForPeripheral(peripheral: CBPeripheral) -> TTDevice? {
        for device: TTDevice in devices {
            if device.peripheral == peripheral {
                return device
            }
        }
        return nil
    }
    
    func objectAtIndex(index: Int) -> TTDevice {
        return devices[index]
    }
    
    // MARK: Devices
    
    func addPeripheral(peripheral: CBPeripheral) -> TTDevice {
        let device = TTDevice(peripheral: peripheral)
        
        self.addDevice(device)

        return device
    }
    
    func addDevice(device: TTDevice) {
        var addDevice = device
        addDevice.isPaired = self.isDevicePaired(addDevice)
        
        for foundDevice in devices {
            if foundDevice.peripheral.identifier.UUIDString == addDevice.peripheral.identifier.UUIDString {
                print(" ---> Already added device: \(foundDevice) - \(addDevice)")
                addDevice = foundDevice
            }
        }
        
        if !devices.contains(addDevice) {
            devices.append(addDevice)
        } else {
            print(" ---> Already added device and not adding again: \(addDevice)")
        }
        
        addDevice.state = .DEVICE_STATE_SEARCHING
    }

    func removePeripheral(peripheral: CBPeripheral) {
        let device: TTDevice? = self.deviceForPeripheral(peripheral)
        if device != nil {
            self.removeDevice(device!)
        }
    }
    
    func removeDevice(device: TTDevice) {
        var removeDevice: TTDevice? = device
        var updatedDevices: [TTDevice] = []
        for foundDevice: TTDevice in devices {
            if foundDevice != removeDevice {
                updatedDevices.append(foundDevice)
            } else {
                foundDevice.peripheral.delegate = nil
                foundDevice.peripheral = nil
                foundDevice.state = .DEVICE_STATE_DISCONNECTED
            }
        }
        
        devices = updatedDevices
        removeDevice = nil;
    }
    
    func ensureDevicesConnected() {
        var updatedConnectedDevices: [TTDevice] = []
        
        for device: TTDevice in devices {
            if device.conncted() {
                updatedConnectedDevices.append(device)
                device.isPaired = self.isDevicePaired(device)
            } else {
                device.peripheral.delegate = nil
                device.peripheral = nil
            }
        }
        
        devices = updatedConnectedDevices
    }
    
    func connectedDeviceAtIndex(index: Int) -> TTDevice? {
        var i = 0
        for device: TTDevice in devices {
            if device.conncted() {
                if i == index {
                    return device
                }
                i += 1
            }
        }
        
        return nil
    }
    
    // MARK: Pairing
    
    func isPeripheralPaired(peripheral: CBPeripheral) -> Bool {
        let prefs = NSUserDefaults.standardUserDefaults()
        let pairedDevices = prefs.arrayForKey("TT:devices:paired") as! [String]?
        
        if pairedDevices == nil {
            return false
        }
        
        return pairedDevices!.contains(peripheral.identifier.UUIDString)
    }
    
    func isDevicePaired(device: TTDevice) -> Bool {
        return self.isPeripheralPaired(device.peripheral)
    }
    
    // MARK: Counting
    
    func count() -> Int {
        return devices.count
    }
    
    func connectedCount() -> Int {
        var count = 0
        for device: TTDevice in devices {
            if device.conncted() {
                count += 1
            }
        }
        
        return count
    }
    
    func totalPairedCount() -> Int {
        let prefs = NSUserDefaults.standardUserDefaults()
        let pairedDevices = prefs.arrayForKey("TT:devices:paired") as! [String]?
        
        if pairedDevices == nil {
            return 0
        }

        return pairedDevices!.count
    }
    
}
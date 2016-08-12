//
//  TTBluetoothManager.swift
//  Turn Touch Bluetooth
//
//  Created by Samuel Clay on 8/11/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth
import MediaPlayer

class TTBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    let DEVICE_V2_SERVICE_BATTERY_UUID                 = "180F"
    let DEVICE_V2_SERVICE_BUTTON_UUID                  = "99c31523-dc4f-41b1-bb04-4e4deb81fadd"
    let DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID    = "2a19"
    let DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID    = "99c31525-dc4f-41b1-bb04-4e4deb81fadd"
    let DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID         = "99c31526-dc4f-41b1-bb04-4e4deb81fadd"
    
    var manager: CBCentralManager!
    var foundPeripherals: [CBPeripheral] = []
    
    var volumeSlider: UISlider {
        get {
            return (MPVolumeView().subviews.filter { NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as! UISlider)
        }
    }
    var lastVolume: Float!

    override init() {
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: dispatch_queue_create("TT.bluetooth.queue", DISPATCH_QUEUE_SERIAL),
                                   options: [CBCentralManagerOptionRestoreIdentifierKey: "TTcentralManageRestoreIdentifier",
                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
                                    CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                                    CBConnectPeripheralOptionNotifyOnNotificationKey: true])
    }
    
    func knownPeripheralIdentifiers() -> [NSUUID] {
        var identifiers: [NSUUID] = []
        let preferences = NSUserDefaults.standardUserDefaults()
        let pairedDevices = preferences.arrayForKey("TT:devices:paired") as! [String]?
        if pairedDevices != nil {
            for identifier: String in pairedDevices! {
                identifiers.append(NSUUID(UUIDString: identifier)!)
            }
        }
        return identifiers
    }

    func isLECapableHardware() -> Bool {
        var state: String? = nil
        switch manager.state {
        case .Unsupported:
            state = "The platform/hardware doesn't support Bluetooth Low Energy."
        case .Unauthorized:
            state = "The app is not authorized to use Bluetooth Low Energy."
        case .PoweredOff:
            state = "Bluetooth is currently powered off."
        case .PoweredOn:
            return true
        case .Unknown:
            state = "Bluetooth in unknown state."
        case .Resetting:
            state = "Bluetooth in resetting state."
        }
        
        print(" ---> Central manager state: \(state) - \(manager)/\(manager.state)", state!, manager, manager.state)
        return false
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        manager = central
        let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as! [CBPeripheral]
        print(" ---> Restoring state: \(peripherals)")
    }
    
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print(" ---> centralManagerDidUpdateState: \(central)/\(manager) - \(central.state) -> \(manager.state)")
        manager = central
        
        if self.isLECapableHardware() {
            
            let peripherals = manager.retrievePeripheralsWithIdentifiers(self.knownPeripheralIdentifiers())
            let connectedPeripherals = manager.retrieveConnectedPeripheralsWithServices([CBUUID(string:"1523")])
            
            for peripheralGroup: [CBPeripheral] in [connectedPeripherals, peripherals] {
                for peripheral: CBPeripheral in peripheralGroup {
                    if foundPeripherals.contains(peripheral) {
                        if peripheral.state == CBPeripheralState.Disconnected {
                            foundPeripherals.removeAtIndex(foundPeripherals.indexOf(peripheral)!)
                        } else {
                            print(" ---> Already discovered peripheral: \(peripheral)")
                            return
                        }
                    }
                    
                    foundPeripherals.append(peripheral)

                    manager.connectPeripheral(peripheral, options: [CBCentralManagerOptionRestoreIdentifierKey: "TTcentralManageRestoreIdentifier",
                        CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
                        CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                        CBConnectPeripheralOptionNotifyOnNotificationKey: true])
                }
            }
            
//            if peripherals.count == 0 && connectedPeripherals.count == 0 {
                manager.scanForPeripheralsWithServices([CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID),
                    CBUUID(string:"1523")], options: nil)
//            }
        }

    }
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral,
                        advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if foundPeripherals.contains(peripheral) {
            print(" ---> Already discovered peripheral: \(peripheral)")
            return
        }

        foundPeripherals.append(peripheral)
        
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as! String
        print(" ---> Found bluetooth peripheral, connecting: \(localName)/\(peripheral) (\(RSSI))")
        manager.connectPeripheral(peripheral, options: [CBCentralManagerOptionRestoreIdentifierKey: "TTcentralManageRestoreIdentifier",
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnNotificationKey: true])
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print(" ---> Connected: \(peripheral)")
        peripheral.delegate = self
        
        peripheral.discoverServices([CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID),
            CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID),
            CBUUID(string:"1523")])
        
        let preferences = NSUserDefaults.standardUserDefaults()
        var pairedDevices = preferences.arrayForKey("TT:devices:paired") as! [String]?
        if pairedDevices == nil {
            pairedDevices = []
        }
        pairedDevices?.append(peripheral.identifier.UUIDString)
        preferences.setObject(pairedDevices, forKey: "TT:devices:paired")
        preferences.synchronize()
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print(" ---> Disconnected device: \(peripheral)")
        foundPeripherals.removeAtIndex(foundPeripherals.indexOf(peripheral)!)
        self.centralManagerDidUpdateState(central)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print(" ---> Failed connect to device: \(peripheral): \(error?.localizedDescription)")
    }
    
    // MARK: CBPeripheral delegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if peripheral.services == nil {
            print(" ---> Nil services: \(peripheral)")
            return
        }
        
        for service: CBService in peripheral.services! {
            if service.UUID.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID)) {
                peripheral.discoverCharacteristics([CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID),
                    CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)], forService: service)
            }
            if service.UUID.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID)) {
                peripheral.discoverCharacteristics([CBUUID(string: DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID)], forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if service.characteristics == nil {
            print(" ---> Nil characteristics: \(peripheral)")
            return
        }
        
        if service.UUID.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID)) {
            for characteristic: CBCharacteristic in service.characteristics! {
                if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                } else if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)) {
                    peripheral.readValueForCharacteristic(characteristic)
                }
            }
        }
        
        if service.UUID.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID)) {
            for characteristic: CBCharacteristic in service.characteristics! {
                if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID)) {
                    peripheral.readValueForCharacteristic(characteristic)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
            print(" ---> Subscribed to \(peripheral)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print(" ---> Value: \(characteristic.value)")
        
        if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
            if characteristic.value != nil {
                print(" ---> Button press: \(characteristic.value)")
                if lastVolume == nil || lastVolume == 0.75 {
                    lastVolume = 0.25
                } else {
                    lastVolume = 0.75
                }
                volumeSlider.setValue(lastVolume, animated: false)
            } else {
                print(" ---> Characteristic error: \(error?.localizedDescription)")
            }
        } else if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)) {
            if (characteristic.value == nil) || (characteristic.value!.length == 0) {
                print(" ---> No nickname: \(characteristic)")
            } else {
                print(" ---> Nickname: \(characteristic.value)")
            }
            
            print(" ---> Hello: \(peripheral)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("peripheral did write: \(characteristic.value)")
    }


}

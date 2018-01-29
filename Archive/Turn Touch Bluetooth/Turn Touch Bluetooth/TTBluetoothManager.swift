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
        
        manager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "TT.bluetooth.queue", attributes: []),
                                   options: [CBCentralManagerOptionRestoreIdentifierKey: "TTcentralManageRestoreIdentifier",
                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
                                    CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                                    CBConnectPeripheralOptionNotifyOnNotificationKey: true])
    }
    
    func knownPeripheralIdentifiers() -> [NSUUID] {
        var identifiers: [NSUUID] = []
        let preferences = UserDefaults.standard
        let pairedDevices = preferences.array(forKey: "TT:devices:paired") as! [String]?
        if pairedDevices != nil {
            for identifier: String in pairedDevices! {
                identifiers.append(NSUUID(uuidString: identifier)!)
            }
        }
        return identifiers
    }

    func isLECapableHardware() -> Bool {
        var state: String? = nil
        switch manager.state {
        case .unsupported:
            state = "The platform/hardware doesn't support Bluetooth Low Energy."
        case .unauthorized:
            state = "The app is not authorized to use Bluetooth Low Energy."
        case .poweredOff:
            state = "Bluetooth is currently powered off."
        case .poweredOn:
            return true
        case .unknown:
            state = "Bluetooth in unknown state."
        case .resetting:
            state = "Bluetooth in resetting state."
        }
        
        print(" ---> Central manager state: \(String(describing: state)) - \(manager)/\(manager.state)", state!, manager, manager.state)
        return false
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState state: [String : Any]) {
        manager = central
        if state[CBCentralManagerRestoredStatePeripheralsKey] != nil {
            let peripherals = state[CBCentralManagerRestoredStatePeripheralsKey] as! [CBPeripheral]
            print(" ---> Restoring state: \(peripherals)")
        }
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(" ---> centralManagerDidUpdateState: \(central)/\(manager) - \(central.state) -> \(manager.state)")
        manager = central
        
        if self.isLECapableHardware() {
            
            let peripherals = manager.retrievePeripherals(withIdentifiers: self.knownPeripheralIdentifiers() as [UUID])
            let connectedPeripherals = manager.retrieveConnectedPeripherals(withServices: [CBUUID(string:"1523")])
            
            for peripheralGroup: [CBPeripheral] in [connectedPeripherals, peripherals] {
                for peripheral: CBPeripheral in peripheralGroup {
                    if foundPeripherals.contains(peripheral) {
                        if peripheral.state == CBPeripheralState.disconnected {
                            foundPeripherals.remove(at: foundPeripherals.index(of: peripheral)!)
                        } else {
                            print(" ---> Already discovered peripheral: \(peripheral)")
                            return
                        }
                    }
                    
                    foundPeripherals.append(peripheral)

                    manager.connect(peripheral, options: [CBCentralManagerOptionRestoreIdentifierKey: "TTcentralManageRestoreIdentifier",
                        CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
                        CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                        CBConnectPeripheralOptionNotifyOnNotificationKey: true])
                }
            }
            
//            if peripherals.count == 0 && connectedPeripherals.count == 0 {
            manager.scanForPeripherals(withServices: [CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID),
                                                      CBUUID(string:"1523")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
//            }
        }

    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if foundPeripherals.contains(peripheral) {
            print(" ---> Already discovered peripheral: \(peripheral)")
            return
        }

        foundPeripherals.append(peripheral)
        
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as! String
        print(" ---> Found bluetooth peripheral, connecting: \(localName)/\(peripheral) (\(RSSI))")
        manager.connect(peripheral, options: [CBCentralManagerOptionRestoreIdentifierKey: "TTcentralManageRestoreIdentifier"])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print(" ---> Connected: \(peripheral)")
        peripheral.delegate = self
        
        peripheral.discoverServices([CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID),
            CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID),
            CBUUID(string:"1523")])
        
        let preferences = UserDefaults.standard
        var pairedDevices = preferences.array(forKey: "TT:devices:paired") as! [String]?
        if pairedDevices == nil {
            pairedDevices = []
        }
        pairedDevices?.append(peripheral.identifier.uuidString)
        preferences.set(pairedDevices, forKey: "TT:devices:paired")
        preferences.synchronize()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(" ---> Disconnected device: \(peripheral)")
        foundPeripherals.remove(at: foundPeripherals.index(of: peripheral)!)
        self.centralManagerDidUpdateState(central)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(" ---> Failed connect to device: \(peripheral): \(error?.localizedDescription ?? "none")")
    }
    
    // MARK: CBPeripheral delegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral.services == nil {
            print(" ---> Nil services: \(peripheral)")
            return
        }
        
        for service: CBService in peripheral.services! {
            if service.uuid.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID)) {
                peripheral.discoverCharacteristics([CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID),
                                                    CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)], for: service)
            }
            if service.uuid.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID)) {
                peripheral.discoverCharacteristics([CBUUID(string: DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID)], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if service.characteristics == nil {
            print(" ---> Nil characteristics: \(peripheral)")
            return
        }
        
        if service.uuid.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID)) {
            for characteristic: CBCharacteristic in service.characteristics! {
                if characteristic.uuid.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
                    peripheral.setNotifyValue(true, for: characteristic)
                } else if characteristic.uuid.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)) {
                    peripheral.readValue(for: characteristic)
                }
            }
        }
        
        if service.uuid.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID)) {
            for characteristic: CBCharacteristic in service.characteristics! {
                if characteristic.uuid.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID)) {
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
            print(" ---> Subscribed to \(peripheral)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(" ---> Value: \(String(describing: characteristic.value))")
        
        if characteristic.uuid.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
            if characteristic.value != nil {
                print(" ---> Button press: \(String(describing: characteristic.value))")
                if lastVolume == nil || lastVolume == 0.75 {
                    lastVolume = 0.25
                } else {
                    lastVolume = 0.75
                }
                volumeSlider.setValue(lastVolume, animated: false)
            } else {
                print(" ---> Characteristic error: \(String(describing: error?.localizedDescription))")
            }
        } else if characteristic.uuid.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)) {
            if (characteristic.value == nil) || (characteristic.value!.count == 0) {
                print(" ---> No nickname: \(characteristic)")
            } else {
                print(" ---> Nickname: \(String(describing: characteristic.value))")
            }
            
            print(" ---> Hello: \(peripheral)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral did write: \(String(describing: characteristic.value))")
    }


}

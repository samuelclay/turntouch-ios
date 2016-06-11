//
//  TTBluetoothMonitor.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation
import CoreBluetooth

enum TTBluetoothState {
    case BT_STATE_IDLE
    case BT_STATE_SCANNING_KNOWN
    case BT_STATE_CONNECTING_KNOWN
    case BT_STATE_SCANNING_UNKNOWN
    case BT_STATE_CONNECTING_UNKNOWN
    case BT_STATE_PAIRING_UNKNOWN
    case BT_STATE_DISCOVER_SERVICES
    case BT_STATE_DISCOVER_CHARACTERISTICS
    case BT_STATE_CHAR_NOTIFICATION
}

class TTBluetoothMonitor: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Firmware rev. 20+ = v2
    let DEVICE_V2_SERVICE_BATTERY_UUID                 = "180F"
    let DEVICE_V2_SERVICE_BUTTON_UUID                  = "99c31523-dc4f-41b1-bb04-4e4deb81fadd"
    let DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID    = "2a19"
    let DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID    = "99c31525-dc4f-41b1-bb04-4e4deb81fadd"
    let DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID         = "99c31526-dc4f-41b1-bb04-4e4deb81fadd"
    
    var manager: CBCentralManager!
    let buttonTimer = TTButtonTimer()
    var batteryLevelTimer: NSTimer!
    var manufacturer: NSString?
    let foundDevices = TTDeviceList()
    var bluetoothState = TTBluetoothState.BT_STATE_IDLE
    var onceUnknownToken: dispatch_once_t = 0
    var onceKnownToken: dispatch_once_t = 0
    
    dynamic var nicknamedConnectedCount: NSNumber?
    dynamic var pairedDevicesCount: NSNumber?
    dynamic var unpairedDevicesCount: NSNumber?
    
    override init() {
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0),
                                   options: [CBCentralManagerOptionRestoreIdentifierKey: "centralManagerIdentifier",
                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true),
                                    CBConnectPeripheralOptionNotifyOnConnectionKey: NSNumber(bool: true),
                                    CBConnectPeripheralOptionNotifyOnNotificationKey: NSNumber(bool: true)])
    }
    
    // MARK: Bluetooth status
    
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
//        default:
//            state = "Bluetooth not in any state!"
        }
        
        print(" ---> Central manager state: \(state) - \(manager)/\(manager.state)", state!, manager, manager.state)
        return false
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
    
    // MARK: Scanning
    
    func scanKnown()  {
        var knownDevicesStillDisconnected = false
        var isActivelyConnecting = false
        
        bluetoothState = .BT_STATE_SCANNING_KNOWN
        print(" ---> (\(bluetoothState)) Scanning known: \(self.knownPeripheralIdentifiers().count) remotes")
        
        let peripherals = manager.retrievePeripheralsWithIdentifiers(self.knownPeripheralIdentifiers())
        for peripheral: CBPeripheral in peripherals {
            var foundDevice = foundDevices.deviceForPeripheral(peripheral)
            if foundDevice == nil {
                foundDevice = foundDevices.addPeripheral(peripheral)
            } else if foundDevice!.state == TTDeviceState.DEVICE_STATE_CONNECTING {
                isActivelyConnecting = true
            }
            
            if peripheral.state != CBPeripheralState.Disconnected && foundDevice!.state != TTDeviceState.DEVICE_STATE_SEARCHING {
                print(" ---> Already connected: \(foundDevice!)")
                continue
            } else {
                knownDevicesStillDisconnected = true
            }
            
            bluetoothState = .BT_STATE_CONNECTING_KNOWN
            print(" ---> (\(bluetoothState)) Attempting connect to known: \(foundDevice)")
            
//            manager.cancelPeripheralConnection(peripheral)
            manager.connectPeripheral(peripheral, options: [CBCentralManagerOptionRestoreIdentifierKey: "centralManagerIdentifier",
                CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true),
                CBConnectPeripheralOptionNotifyOnConnectionKey: NSNumber(bool: true),
                CBConnectPeripheralOptionNotifyOnNotificationKey: NSNumber(bool: true)])
        }
        
        if !knownDevicesStillDisconnected {
            bluetoothState = .BT_STATE_IDLE
            print(" ---> (\(bluetoothState)) All done, no known devices left to connect.")
        }
        
        if !isActivelyConnecting && self.knownPeripheralIdentifiers().count == 0 {
            self.scanUnknown()
            return
        }
        
        // Search for unpaired devices or paired devices that aren't responding to `connectPeripheral`
        
        dispatch_once(&onceUnknownToken) {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(60 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.onceUnknownToken = 0
                if self.bluetoothState != .BT_STATE_SCANNING_KNOWN && self.bluetoothState != .BT_STATE_CONNECTING_KNOWN {
                    print(" ---> (\(self.bluetoothState)) Not scanning for unpaired, since not scanning known.")
                    return
                }
                
                print(" ---> (\(self.bluetoothState)) Starting scan for unpaired...")
                self.stopScan()
                self.scanUnknown()
            })
        }
    }
    
    func scanUnknown() {
        if bluetoothState == .BT_STATE_PAIRING_UNKNOWN {
            print(" ---> (\(bluetoothState)) Not scanning unknown since in pairing state.")
            return
        }
        
        if bluetoothState == .BT_STATE_CONNECTING_UNKNOWN {
            for device: TTDevice in foundDevices.devices {
                if device.state == TTDeviceState.DEVICE_STATE_CONNECTING {
                    print(" ---> (\(bluetoothState)) [Scanning unknown] Canceling peripheral connection: \(device)")
//                    manager.cancelPeripheralConnection(device.peripheral)
                }
            }
            print(" ---> (\(bluetoothState)) [Scanning unknown] Not scanning unknown, already connecting to unknown")
            return
        }
        
        self.stopScan()
        
        bluetoothState = .BT_STATE_SCANNING_UNKNOWN
        print(" ---> (\(bluetoothState)) Scanning unknown")
        
        manager.scanForPeripheralsWithServices([CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID),
                CBUUID(string:"1523")], options: nil)
    }
    
    func stopScan() {
        print(" ---> (\(bluetoothState)) Stopping scan.")
        manager.stopScan()
    }
    
    // MARK: Background
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        manager = central
        let peripherals: [CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as! [CBPeripheral]
        print(" ---> Restoring state: \(peripherals)")
        for peripheral in peripherals {
            peripheral.delegate = self
            manager.connectPeripheral(peripheral, options: [CBCentralManagerOptionRestoreIdentifierKey: "centralManagerIdentifier",
                CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true),
                CBConnectPeripheralOptionNotifyOnConnectionKey: NSNumber(bool: true),
                CBConnectPeripheralOptionNotifyOnNotificationKey: NSNumber(bool: true)])
        }
    }
    
    // MARK: CBCentralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print(" ---> (\(bluetoothState)) centralManagerDidUpdateState: \(central)/\(manager) - \(central.state) -> \(manager.state)")
        manager = central
        self.updateBluetoothState(false)
    }
    
    func updateBluetoothState(renew: Bool) {
        if renew {
            print(" ---> (\(bluetoothState)) Renewing CB manager ... EXCEPT NOT. Why are you here?")
//            if manager {
//                self.terminate()
//            }
//            manager = CBCentralManager(
        }
        
        self.stopScan()
        if self.isLECapableHardware() {
            self.scanKnown()
        } else {
            self.countDevices()
            // TODO: Remove this and switch to notification-based reconnects
//            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(30 * Double(NSEC_PER_SEC)))
//            dispatch_after(delayTime, dispatch_get_main_queue(), {
//                self.reconnect(false)
//            })
        }
    }
    
//    func reconnect(renew: Bool) {
//        // Only force a reconnection if nothing connected
//        if !renew {
//            for device in foundDevices.devices {
//                if device.state == TTDeviceState.DEVICE_STATE_CONNECTED {
//                    return
//                }
//            }
//        }
//        
//        self.stopScan()
//        self.terminate()
//        self.updateBluetoothState(true)
//    }
    
    // func terminate
    
    func countDevices() {
        foundDevices.ensureDevicesConnected()
        
//        self.setValue(foundDevices.nicknamedCount(), forKey: "nicknamedConnectedCount")
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral,
                        advertisementData: [String : AnyObject], RSSI: NSNumber) {
        var device = foundDevices.deviceForPeripheral(peripheral)
        if device == nil {
            device = foundDevices.addPeripheral(peripheral)
        }
        bluetoothState = .BT_STATE_CONNECTING_UNKNOWN
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as! String
        print(" ---> (\(bluetoothState)) Found bluetooth peripheral, connecting: \(localName)/\(device) (\(RSSI))")
        
        self.stopScan()
        var isAlreadyConnecting = false
        for foundDevice: TTDevice in foundDevices.devices {
            if foundDevice.peripheral == peripheral {
                isAlreadyConnecting = false
                break
            } else if foundDevice.state == TTDeviceState.DEVICE_STATE_CONNECTING {
                print(" ---> (\(bluetoothState)) Connected to another, canceling: \(foundDevice)/\(peripheral)")
                isAlreadyConnecting = true
            }
            
        }
        
        if isAlreadyConnecting {
//            manager.cancelPeripheralConnection(peripheral)
        } else {
            manager.connectPeripheral(peripheral, options: [CBCentralManagerOptionRestoreIdentifierKey: "centralManagerIdentifier",
                CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool: true),
                CBConnectPeripheralOptionNotifyOnConnectionKey: NSNumber(bool: true),
                CBConnectPeripheralOptionNotifyOnNotificationKey: NSNumber(bool: true)])
        }
        
        // In case still connecting 30 seconds from now, disconnect
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(30 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            if self.bluetoothState != .BT_STATE_CONNECTING_UNKNOWN {
                return
            }
            self.bluetoothState = .BT_STATE_IDLE
            self.stopScan()
            self.scanKnown()
        })
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        let device = foundDevices.deviceForPeripheral(peripheral)! as TTDevice
        
        for foundDevice: TTDevice in foundDevices.devices {
            if foundDevice.state == TTDeviceState.DEVICE_STATE_CONNECTING && foundDevice.peripheral == peripheral {
                print(" ---> (\(bluetoothState)) Connecting to another, canceling: \(foundDevice)/\(peripheral)")
//                manager.cancelPeripheralConnection(peripheral)
                return
            }
        }
        
        peripheral.delegate = self
    
        print(" ---> (\(bluetoothState)) Connected: \(device)")
        
        if device.isPaired {
            device.state = TTDeviceState.DEVICE_STATE_CONNECTING
            device.needsReconnection = false
            
            self.countDevices()
            
            bluetoothState = .BT_STATE_DISCOVER_SERVICES
        } else {
            // Never seen before, start pairing
            bluetoothState = .BT_STATE_PAIRING_UNKNOWN
            
            device.state = TTDeviceState.DEVICE_STATE_CONNECTING
            device.needsReconnection = false
            
             buttonTimer.resetPairingState()
            self.countDevices()
            
            let noPairedDevices = foundDevices.totalPairedCount() == 0
            if noPairedDevices {
                // appDelegate().mainViewController.switchPanelModalPairing(.MODAL_PAIRING_INTRO)
            }
        }

        
        peripheral.discoverServices([CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID),
            CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID),
            CBUUID(string:"1523")])
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let device = foundDevices.deviceForPeripheral(peripheral)
        print(" ---> (\(bluetoothState)) Disconnected device: \(device)")
        
        foundDevices.removePeripheral(peripheral)
        self.countDevices()
        self.scanKnown()
        
        dispatch_once(&onceKnownToken) {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.onceKnownToken = 0
                self.scanKnown()
            })
        }
        
        // TODO: hudController release toast mode + action
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let device = foundDevices.deviceForPeripheral(peripheral)
        print(" ---> (\(bluetoothState)) Failed connect to device: \(device)-\(peripheral): \(error?.localizedDescription)")
        
        foundDevices.removePeripheral(peripheral)
        self.countDevices()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            self.stopScan()
            self.scanKnown()
        })
    }
    
    // MARK: CBPeripheral delegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        bluetoothState = .BT_STATE_DISCOVER_CHARACTERISTICS
        let device = foundDevices.deviceForPeripheral(peripheral)!

        for service: CBService in peripheral.services! {
            if service.UUID.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID)) {
                device.firmwareVersion = 2
                peripheral.discoverCharacteristics([CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID),
                    CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)], forService: service)
            }
            if service.UUID.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID)) {
                device.firmwareVersion = 2
                peripheral.discoverCharacteristics([CBUUID(string: DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID)], forService: service)
            }
//            // Device Information Service
//            if service.UUID.isEqual(CBUUID(string: "180A")) {
//                device.firmwareVersion = 2
//                peripheral.discoverCharacteristics([CBUUID(string: "2A29")], forService: service)
//            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        bluetoothState = .BT_STATE_CHAR_NOTIFICATION

        if service.characteristics == nil {
            return
        }
        
        if service.UUID.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BUTTON_UUID)) {
            for characteristic: CBCharacteristic in service.characteristics! {
                if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    let device = foundDevices.deviceForPeripheral(peripheral)
                    device?.buttonStatusChar = characteristic
                } else if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)) {
                    peripheral.readValueForCharacteristic(characteristic)
                }
            }
        }
        
        if service.UUID.isEqual(CBUUID(string: DEVICE_V2_SERVICE_BATTERY_UUID)) {
            for characteristic: CBCharacteristic in service.characteristics! {
                if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BATTERY_LEVEL_UUID)) {
                    peripheral.readValueForCharacteristic(characteristic)
                    self.delayBatteryLevelReading()
                }
            }
        }
        
//        if service.UUID.isEqual(CBUUID(string: "180A")) {
//            for characteristic: CBCharacteristic in service.characteristics! {
//                if characteristic.UUID.isEqual(CBUUID(string: "2A29")) {
//                    peripheral.readValueForCharacteristic(characteristic)
//                }
//            }
//        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
            let device = foundDevices.deviceForPeripheral(peripheral)!
            print(" ---> (\(bluetoothState)) Subscribed to \(device)")
            
            device.isNotified = true
            device.state = TTDeviceState.DEVICE_STATE_CONNECTED
            self.countDevices()
            
            bluetoothState = .BT_STATE_IDLE
            self.scanKnown()
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        let device = foundDevices.deviceForPeripheral(peripheral)!
        print(" ---> Value: \(characteristic.value)")
        
        if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_BUTTON_STATUS_UUID)) {
            if characteristic.value != nil {
                print(" ---> \(bluetoothState) Button press: \(characteristic.value?.hexadecimalString)")
                if device.isPaired {
                    buttonTimer.readBluetoothData(characteristic.value!)
                } else {
                    buttonTimer.readBluetoothDataDuringPairing(characteristic.value!)
                    if buttonTimer.isDevicePaired() {
                        self.pairDeviceSuccess(peripheral)
                    }
                }
                device.lastActionDate = NSDate()
            } else {
                print(" ---> \(bluetoothState) Characteristic error: \(error?.localizedDescription)")
            }
        } else if characteristic.UUID.isEqual(CBUUID(string: DEVICE_V2_CHARACTERISTIC_NICKNAME_UUID)) {
            if (characteristic.value == nil) || (characteristic.value!.length == 0) {
                print(" ---> \(bluetoothState) No nickname: \(device)")
            }
            device.setNicknameData(characteristic.value!)
            self.countDevices()
            
            print(" ---> \(bluetoothState) Hello: \(device)")
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.ensureNicknameOnDevice(device)
            })
        }

    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("peripheral did write: \(characteristic.value)")
    }
    
    // MARK: Firmware options and customization
    
    func ensureNicknameOnDevice(device: TTDevice) {
        
    }
    
    func writeNicknameToDevice(device: TTDevice, nickname: String) {
        
    }
    
    func clearDataOfNullBytes(data: NSMutableData) {
        
    }
    
    // MARK: Battery
    
    func delayBatteryLevelReading() {
        
    }
    
    func updateBatteryLevel(timer: NSTimer) {
        
    }
    
    // MARK: Pairing
    
    func pairDeviceSuccess(peripheral: CBPeripheral) {
        let preferences = NSUserDefaults.standardUserDefaults()
        var pairedDevices = preferences.arrayForKey("TT:devices:paired") as! [String]?
        if pairedDevices == nil {
            pairedDevices = []
        }
        pairedDevices?.append(peripheral.identifier.UUIDString)
        preferences.setObject(pairedDevices, forKey: "TT:devices:paired")
        preferences.synchronize()
        
        buttonTimer.resetPairingState()
        self.countDevices()
        appDelegate().modeMap.activeModeDirection = .NO_DIRECTION
        // appDelegate().mainViewController.switchPanelModalPairing(.MODAL_PAIRING_SUCCESS)
    }
    
    func disconnectUnpairedDevices() {
        
    }
    
    func characteristicInPeripheral(peripheral: CBPeripheral, serviceUUID: String, characteristicUUID: String) -> CBCharacteristic? {
        for service: CBService in peripheral.services! {
            if service.UUID.isEqual(CBUUID(string: serviceUUID)) {
                for characteristic: CBCharacteristic in service.characteristics! {
                    if characteristic.UUID.isEqual(CBUUID(string: characteristicUUID)) {
                        return characteristic
                    }
                }
            }
        }
        
        return nil
    }
}


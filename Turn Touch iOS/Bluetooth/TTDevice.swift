//
//  TTDevice.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation
import CoreBluetooth

enum TTDeviceState {
    case DEVICE_STATE_DISCONNECTED
    case DEVICE_STATE_SEARCHING
    case DEVICE_STATE_CONNECTING
    case DEVICE_STATE_CONNECTED
}

class TTDevice: NSObject {
    
    var nickname: String?
    var uuid: String!
    var peripheral: CBPeripheral!
    var buttonStatusChar: CBCharacteristic!
    var batteryPct: NSNumber!
    var lastActionDate: NSDate!
    var isPaired = false
    var isNotified = false
    var needsReconnection = false
    var inDFU = false
    var firmwareVersion: Int!
    var isFirmwareOld = false
    var state: TTDeviceState = .DEVICE_STATE_DISCONNECTED
    
    init(peripheral newPeripheral: CBPeripheral) {
        super.init()
        peripheral = newPeripheral
        uuid = peripheral.identifier.UUIDString
    }
    
    override var description : String {
        let connected = state == .DEVICE_STATE_CONNECTED ? "connected" : "X"
        let paired = isPaired ? "PAIRED" : "unpaired"
        let uuidSubstr = NSString(string: uuid).substringToIndex(8)
        
        return "\(uuidSubstr) / \(nickname) (\(connected)-\(paired))"
    }
    
    func setNicknameData(nicknameData: NSData) {
        let fixedNickname = NSMutableData()
        
        let bytes = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(nicknameData.bytes), count: nicknameData.length))
        var dataLength = 0
        
        for i in 0..<nicknameData.length {
            if bytes[i] != 0x00 {
                dataLength += 1
            } else {
                break
            }
        }
        fixedNickname.appendBytes(bytes, length: dataLength)
        
        nickname = String(data: fixedNickname, encoding: NSUTF8StringEncoding)
    }
    
    func setFirmwareVersion(firmwareVersion version: Int) {
        firmwareVersion = version
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let latestVersion = prefs.integerForKey("TT:firmware:version")
        
        isFirmwareOld = firmwareVersion < latestVersion
    }
    
    func conncted() -> Bool {
        let bluetoothConnected = peripheral.state == CBPeripheralState.Connected
        let connecting = state == .DEVICE_STATE_CONNECTED || state == .DEVICE_STATE_CONNECTING
        
        return bluetoothConnected && connecting
    }
}
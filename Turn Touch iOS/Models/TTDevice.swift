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
    case device_STATE_DISCONNECTED
    case device_STATE_SEARCHING
    case device_STATE_CONNECTING
    case device_STATE_CONNECTED
}

class TTDevice: NSObject {
    
    var nickname: String?
    var uuid: String!
    var peripheral: CBPeripheral!
    var buttonStatusChar: CBCharacteristic!
    var batteryPct: NSNumber?
    var lastActionDate: Date?
    var isPaired = false
    var isNotified = false
    var needsReconnection = false
    @objc dynamic var inDFU = false
    var firmwareVersion: Int?
    @objc dynamic var isFirmwareOld = false
    var state: TTDeviceState = .device_STATE_DISCONNECTED
    
    init(peripheral newPeripheral: CBPeripheral) {
        super.init()
        
        peripheral = newPeripheral
        uuid = peripheral.identifier.uuidString
        
        let prefs = preferences()
        let nicknameKey = "TT:device:\(uuid ?? "nil"):nickname"
        nickname = prefs.string(forKey: nicknameKey)
    }
    
    override var description : String {
        let connected = self.stateLabel()
        let paired = isPaired ? "PAIRED" : "unpaired"
        let uuidSubstr = NSString(string: uuid).substring(to: 8)

        return "\(uuidSubstr) / \(nickname ?? "[no nickname yet]") (\(connected)-\(paired)) (\(peripheral.description))"
    }
    
    func stateLabel() -> String {
        return state == .device_STATE_CONNECTED ? (self.isPaired ? "connected" : "pairing") :
            state == .device_STATE_SEARCHING ? "searching" :
            state == .device_STATE_CONNECTING ? "connecting" :
            state == .device_STATE_DISCONNECTED ? "disconnected" : "X"
    }
    
    func setNicknameData(_ nicknameData: Data) {
        let fixedNickname = NSMutableData()
        
        let bytes = Array(UnsafeBufferPointer(start: (nicknameData as NSData).bytes.bindMemory(to: UInt8.self, capacity: nicknameData.count), count: nicknameData.count))
        var dataLength = 0
        
        for i in 0..<nicknameData.count {
            if bytes[i] != 0x00 {
                dataLength += 1
            } else {
                break
            }
        }
        fixedNickname.append(bytes, length: dataLength)
        
        nickname = String(data: fixedNickname as Data, encoding: String.Encoding.utf8)
    }
    
    func setFirmwareVersion(firmwareVersion version: Int) {
        firmwareVersion = version
        
        let prefs = preferences()
        let latestVersion = prefs.integer(forKey: "TT:firmware:version")
        
        isFirmwareOld = firmwareVersion! < latestVersion
    }
    
    func connected() -> Bool {
        let bluetoothConnected = peripheral.state == CBPeripheralState.connected
        let connecting = state == .device_STATE_CONNECTED //|| state == .DEVICE_STATE_CONNECTING
        
        return bluetoothConnected && connecting
    }
}

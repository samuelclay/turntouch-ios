//
//  TTModeWemoMulticastServer.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

let MULTICAST_GROUP_IP = "239.255.255.250"

protocol TTModeWemoMulticastDelegate {
    func foundDevice(_ headers: [String: String], host: String, port: Int, name: String?, serialNumber: String?, macAddress: String?,  live: Bool) -> TTModeWemoDevice
    func finishScanning()
}

class TTModeWemoMulticastServer: NSObject, GCDAsyncUdpSocketDelegate {

    var delegate: TTModeWemoMulticastDelegate?
    var udpSocket: GCDAsyncUdpSocket!
    var attemptsLeft: Int = 0

    func beginBroadcast() {
        attemptsLeft = 5
        self.createMulticastReceiver()
    }
    
    func deactivate() {
        if udpSocket != nil {
            do {
                udpSocket.pauseReceiving()
                try udpSocket.leaveMulticastGroup(MULTICAST_GROUP_IP)
            } catch let e {
                print(" ---> Multicast error: \(e)")
            }
            udpSocket.close()
            udpSocket = nil
        }
        attemptsLeft = 0
    }
    
    deinit {
        self.deactivate()
    }
    
    // MARK: Multicast Receive
    
    func createMulticastReceiver() {
        if udpSocket == nil {
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
            do {
                try udpSocket.bind(toPort: 7700)
            } catch let e {
                print(" ---> Error binding to port: \(e)")
            }
            
            do {
                try udpSocket.joinMulticastGroup(MULTICAST_GROUP_IP)
            } catch let e {
                print(" ---> Error joining multicast group: \(e)")
            }
            
            do {
                try udpSocket.beginReceiving()
            } catch let e {
                print(" ---> Error receiving: \(e)")
            }
        }
        
        let message = ["M-SEARCH * HTTP/1.1",
                       "HOST:239.255.255.250:1900",
                       "ST:upnp:rootdevice",
                       "MX:2",
                       "MAN:\"ssdp:discover\"",
                       "USER-AGENT: Turn Touch iOS Wemo Finder",
                       "", ""].joined(separator: "\r\n")
        if let data = message.data(using: String.Encoding.utf8) {
            udpSocket.send(data, toHost: MULTICAST_GROUP_IP, port: 1900, withTimeout: TimeInterval(3), tag: 0)
        }
        let tt = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: tt) {
            if self.attemptsLeft == 0 || self.udpSocket == nil {
                self.delegate?.finishScanning()
                return
            }
            self.attemptsLeft -= 1
            print(" ---> Attempting wemo search, \(self.attemptsLeft) attempts left...")
            self.createMulticastReceiver()
        }
    }
    
    // MARK: Match Belkin
    
    func checkDevice(_ data: NSString, host: String, port: UInt16) {
        var headers: [String: String] = [:]
        
        for line: String in data.components(separatedBy: "\r\n") {
            if let match = line.range(of: ":") {
                if line.count > line.distance(from: line.startIndex, to: match.lowerBound) + 2 {
                    let key = line[..<match.lowerBound].lowercased()
                    let value = line[line.index(match.lowerBound, offsetBy: 2)...].trimmingCharacters(in: CharacterSet.whitespaces)
                    headers[key] = value
                }
            }
        }
        
        if let userAgent = headers["x-user-agent"] {
            if userAgent.contains("redsonic") {
                // redsonic = belkin
                if let setupXmlLocation = headers["location"] {
                    let setupXmlUrl = URL(string: setupXmlLocation)
                    let locationHost = setupXmlUrl?.host
                    let locationPort = (setupXmlUrl as NSURL?)?.port?.intValue
                    
                    if locationHost != nil && locationPort != nil {
                        _ = delegate?.foundDevice(headers, host: locationHost!, port: locationPort!, name: nil, serialNumber: nil, macAddress: nil, live: true)
                    }
                }
            }
        }
    }
    
    // MARK: Async delegate
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if let host = GCDAsyncUdpSocket.host(fromAddress: address) {
            let port = GCDAsyncUdpSocket.port(fromAddress: address)
            self.checkDevice(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!,
                             host: host,
                             port: port)
        }
    }

    @nonobjc func udpSocketDidClose(_ sock: GCDAsyncUdpSocket!, withError error: Error!) {
        print(" ---> Closing UDP socket.")
    }
}

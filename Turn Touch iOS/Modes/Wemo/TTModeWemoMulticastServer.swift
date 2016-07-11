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
    func foundDevice(headers: [String: String], host: String, port: Int, name: String?, live: Bool) -> TTModeWemoDevice
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
        
    }
    
    deinit {
        do {
            try udpSocket.leaveMulticastGroup(MULTICAST_GROUP_IP)
        } catch let e {
            print(" ---> Multicast error: \(e)")
        }
        udpSocket.close()
        attemptsLeft = 0
    }
    
    // MARK: Multicast Receive
    
    func createMulticastReceiver() {
        if udpSocket == nil {
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            
            do {
                try udpSocket.bindToPort(7700)
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
                       "", ""].joinWithSeparator("\r\n")
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        udpSocket.sendData(data, toHost: MULTICAST_GROUP_IP, port: 1900, withTimeout: NSTimeInterval(5), tag: 0)
        let tt = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)));
        dispatch_after(tt, dispatch_get_main_queue()) {
            if self.attemptsLeft == 0 || self.udpSocket == nil {
                return
            }
            self.attemptsLeft -= 1
            print(" ---> Attempting wemo search, \(self.attemptsLeft) attempts left...")
            self.createMulticastReceiver()
        }
    }
    
    // MARK: Match Belkin
    
    func checkDevice(data: NSString, host: String, port: UInt16) {
        var headers: [String: String] = [:]
        
        for line: String in data.componentsSeparatedByString("\r\n") {
            if let match = line.rangeOfString(":") {
                let key = line.substringToIndex(match.startIndex).lowercaseString
                let value = line.substringFromIndex(match.startIndex.advancedBy(1)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                headers[key] = value
            }
        }
        
        if let userAgent = headers["x-user-agent"] {
            if userAgent.containsString("redsonic") {
                // redsonic = belkin
                if let setupXmlLocation = headers["location"] {
                    let setupXmlUrl = NSURL(string: setupXmlLocation)
                    let locationHost = setupXmlUrl?.host
                    let locationPort = setupXmlUrl?.port?.integerValue
                    
                    if locationHost != nil && locationPort != nil {
                        delegate?.foundDevice(headers, host: locationHost!, port: locationPort!, name: nil, live: true)
                    }
                }
            }
        }
    }
    
    // MARK: Async delegate
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        self.checkDevice(NSString(data: data, encoding: NSUTF8StringEncoding)!,
                         host: GCDAsyncUdpSocket.hostFromAddress(address),
                         port: GCDAsyncUdpSocket.portFromAddress(address))
    }
    
    func udpSocketDidClose(sock: GCDAsyncUdpSocket!, withError error: NSError!) {
        print(" ---> Closing UDP socket. \(error)")
    }
}

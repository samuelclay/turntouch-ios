//
//  TTModeWemoDevice.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTWemoDeviceState {
    case On
    case Off
}

protocol TTModeWemoDeviceDelegate {
    func deviceReady(device: TTModeWemoDevice)
}

class TTModeWemoDevice: NSObject {
    var deviceName: String!
    var ipAddress: String
    var port: Int
    var deviceState: TTWemoDeviceState!
    var delegate: TTModeWemoDeviceDelegate!
    
    init(ipAddress: String, port: Int) {
        self.ipAddress = ipAddress
        self.port = port
    }
    
    func isEqualToDevice(device: TTModeWemoDevice) -> Bool {
        let sameAddress = ipAddress == device.ipAddress
        let samePort = port == device.port
        
        return sameAddress && samePort
    }
    
    func location() -> String {
        return "\(ipAddress):\(port)"
    }
    
    func requestDeviceInfo(attemptsLeft: Int = 5) {
        if attemptsLeft == 0 {
            print(" ---> Error, could not find wemo setup.xml: \(self.location())")
        }
        
        let attemptsLeft = attemptsLeft - 1
        let url = NSURL(string: "http://\(self.location())/setup.xml")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let responseData = data {
                            self.parseSetupXml(responseData)
                        } else {
                            print(" ---> Retrying setup.xml fetch...")
                            self.requestDeviceInfo(attemptsLeft)
                        }
                    }
                }
            } else {
                print(" ---> Wemo REST error: \(connectionError)")
            }
        }
    }
    
    func parseSetupXml(data: NSData) {
        
    }
    
    func requestDeviceState(callback: () -> Void) {
        
    }
    
    func changeDeviceState(state: TTWemoDeviceState) {
        
    }
}

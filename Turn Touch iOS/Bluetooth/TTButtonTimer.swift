//
//  TTButtonTimer.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation
import AudioToolbox

enum TTPressState: Int {
    case active = 0x01
    case toggle = 0x02
    case mode = 0x03
}

enum TTHUDMenuState {
    case hidden
    case active
}

let DOUBLE_CLICK_ACTION_DURATION = 0.25

class TTButtonTimer : NSObject {
    
    var activeModeTimer: Timer!
    var previousButtonState = TTButtonState()
    var pairingButtonState: TTButtonState!
    var lastButtonPressedDirection: TTModeDirection = .no_DIRECTION
    var lastButtonPressStart: Date!
    var holdToastStart: Date!
    var menuHysteresis = false
    
    var pairingActivatedCount: NSNumber!
    var skipButtonActions = false
    var menuState: TTHUDMenuState = .hidden
    
    func bytesFromData(_ data: Data) -> [UInt8] {
        let count = data.count / MemoryLayout<UInt8>.size
        var array = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&array, length: count * MemoryLayout<UInt8>.size)
        
        return array
    }
    
    func buttonDownStateFromData(_ data: Data) -> UInt8 {
        let range:Range<Int> = 0..<1
        let bytes = self.bytesFromData(data.subdata(in: range))
        return UInt8(~(bytes[0]) & 0xF)
    }
    
    func doubleStateFromData(_ data: Data) -> UInt8 {
        let range:Range<Int> = 0..<1
        let bytes = self.bytesFromData(data.subdata(in: range))
        let state = UInt8(~(bytes[0]) & 0xF0)
        return state >> 4
    }
    
    func heldStateFromData(_ data: Data) -> Bool {
        let range:Range<Int> = 1..<2
        let bytes = self.bytesFromData(data.subdata(in: range))
        return bytes[0] == 0xFF
    }
    
    func readBluetoothData(_ data: Data) {
        let state = self.buttonDownStateFromData(data)
        let doubleState = self.doubleStateFromData(data)
        let heldState = self.heldStateFromData(data)
        var buttonLifted = -1
        
        let latestButtonState = TTButtonState()
        latestButtonState.north = (state & (1 << 0)) != 0x0
        latestButtonState.east = (state & (1 << 1)) != 0x0
        latestButtonState.west = (state & (1 << 2)) != 0x0
        latestButtonState.south = (state & (1 << 3)) != 0x0
        
//        print(" ---> Bluetooth data: \(data) (\(doubleState)/\(state)/\(heldState)) was:\(previousButtonState) is:\(latestButtonState)")
        
        var i = latestButtonState.count
        while i > 0 {
            i -= 1
            if !previousButtonState.state(i) && latestButtonState.state(i) {
                // Press button down
            } else if previousButtonState.state(i) && !latestButtonState.state(i) {
                // Lift button
                buttonLifted = i;
            } else {
                // Button remains pressed down
            }
        }
        
        let anyButtonHeld = !latestButtonState.inMultitouch() && !menuHysteresis && heldState
        let anyButtonPressed = !menuHysteresis && latestButtonState.anyPressedDown()
        let anyButtonLifted = !previousButtonState.inMultitouch() && !menuHysteresis && buttonLifted >= 0
        
        if anyButtonHeld {
            // Hold button down
            print(" ---> Hold button")
            previousButtonState = latestButtonState
            menuState = .hidden
            
            if state == 0x01 {
                // Don't fire action on button release
                previousButtonState.north = false
                self.activateMode(.north)
            } else if state == 0x02 {
                previousButtonState.east = false
                self.activateMode(.east)
            } else if state == 0x04 {
                previousButtonState.west = false
                self.activateMode(.west)
            } else if state == 0x08 {
                previousButtonState.south = false
                self.activateMode(.south)
            }
            self.activateButton(.no_DIRECTION)
        } else if anyButtonPressed {
//            print(" ---> Press down button \(previousButtonState.inMultitouch() ? "(multi-touch)" : "")")
            previousButtonState = latestButtonState
            
            if latestButtonState.inMultitouch() {
                if holdToastStart == nil && !menuHysteresis && menuState == .hidden {
                    holdToastStart = Date()
                    menuHysteresis = true
                    menuState = .active
//                    appDelegate().hudController.holdToastActiveMode(false)
                } else if menuState == .active && !menuHysteresis {
                    menuHysteresis = true
                    menuState = .hidden
                    self.releaseToastActiveMode()
                }
                self.activateButton(.no_DIRECTION)
            } else if menuState == .active {
                if (state & 0x01) == 0x01 {
                    self.fireMenuButton(.north)
                } else if (state & 0x02) == 0x02 {
                    // Not on button down, wait for button up
                } else if (state & 0x08) == 0x08 {
                    self.fireMenuButton(.south)
                } else if state == 0x00 {
                    self.activateButton(.no_DIRECTION)
                }
            } else {
                if (state & 0x01) == 0x01 {
                    self.activateButton(.north)
                } else if (state & 0x02) == 0x02 {
                    self.activateButton(.east)
                } else if (state & 0x04) == 0x04 {
                    self.activateButton(.west)
                } else if (state & 0x08) == 0x08 {
                    self.activateButton(.south)
                } else if state == 0x00 {
                    self.activateButton(.no_DIRECTION)
                }
            }
        } else if anyButtonLifted {
            // Press up button
            previousButtonState = latestButtonState
            var buttonPressedDirection: TTModeDirection!
            switch buttonLifted {
            case 0:
                buttonPressedDirection = .north
            case 1:
                buttonPressedDirection = .east
            case 2:
                buttonPressedDirection = .west
            case 3:
                buttonPressedDirection = .south
            default:
                buttonPressedDirection = .no_DIRECTION
            }
            
//            print(" ---> Lift button\(previousButtonState.inMultitouch() ? " (multi-touch)" : ""): \(buttonPressedDirection)")
            
            if menuState == .active {
                if buttonPressedDirection == .north {
                    // Fired on button down
                } else if buttonPressedDirection == .east {
                    self.fireMenuButton(.east)
                } else if buttonPressedDirection == .west {
                    self.fireMenuButton(.west)
                } else if state == 0x00 {
                    self.activateButton(.no_DIRECTION)
                }
            } else if (doubleState == 0xF &&
                       lastButtonPressedDirection != .no_DIRECTION &&
                       buttonPressedDirection == lastButtonPressedDirection &&
                       Date().timeIntervalSince(lastButtonPressStart) < DOUBLE_CLICK_ACTION_DURATION) {
                // Double click detected
                self.fireDoubleButton(buttonPressedDirection)
                lastButtonPressedDirection = .no_DIRECTION
                lastButtonPressStart = nil
            } else if doubleState != 0xF && doubleState != 0x0 {
                // Firmware v3 has hardware support for double-click
                self.fireDoubleButton(buttonPressedDirection)
            } else {
                lastButtonPressedDirection = buttonPressedDirection
                lastButtonPressStart = Date()
                
                self.fireButton(buttonPressedDirection)
                
                let delayTime = DispatchTime.now() + Double(Int64(DOUBLE_CLICK_ACTION_DURATION * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                    self.lastButtonPressStart = nil
                    self.lastButtonPressedDirection = .no_DIRECTION
                })
            }
        } else if !latestButtonState.anyPressedDown() {
            let inMultitouch = previousButtonState.inMultitouch()
            previousButtonState = latestButtonState
            
            if !inMultitouch && buttonLifted >= 0 && menuHysteresis {
                self.releaseToastActiveMode()
            } else if menuState == .hidden {
                self.releaseToastActiveMode()
            }
            self.activateButton(.no_DIRECTION)
            menuHysteresis = false
            menuState = .hidden
            holdToastStart = nil
        }
    }
    
    func releaseToastActiveMode() {
//        appDelegate().hudController.releaseToastActiveMode()
        
        holdToastStart = nil
    }
    
    func activateMode(_ direction: TTModeDirection) {
        DispatchQueue.main.async(execute: {
            appDelegate().modeMap.switchMode(direction, modeChangeType: .remoteButton)
    //        appDelegate().hudController.holdToastActiveMode(true)
        })
    }
    
    func activateButton(_ direction: TTModeDirection) {
        DispatchQueue.main.async(execute: {
            appDelegate().modeMap.activeModeDirection = direction
            
    //        let actionnNme = appDelegate().modeMap.selectedMode.actionNameInDirection(direction)
    //        appDelegate().hudController.holdToastActiveAction(actionName, direction: direction)
            
            if direction != .no_DIRECTION {
                // Mac has a timer here that shows the HUD. May not be necessary on iOS
            }
        })
    }
    
    func fireMenuButton(_ direction: TTModeDirection) {
        DispatchQueue.main.async(execute: {
//        appDelegate().hudController.modeHUDController.runDirection(direction)
        })
    }
    
    func fireButton(_ direction: TTModeDirection) {
        DispatchQueue.main.async(execute: {
            appDelegate().modeMap.activeModeDirection = direction
            if !self.skipButtonActions {
                appDelegate().modeMap.runActiveButton()
            } else {
                appDelegate().modeMap.activeModeDirection = .no_DIRECTION
            }
            
    //        let actionnNme = appDelegate().modeMap.selectedMode.actionNameInDirection(direction)
    //        appDelegate().hudController.toastActiveAction(actionName, direction: direction)
        })
    }
    
    func fireDoubleButton(_ direction: TTModeDirection) {
        DispatchQueue.main.async(execute: {
            if direction == .no_DIRECTION {
                return
            }
            
            if !self.skipButtonActions {
                appDelegate().modeMap.runDoubleButton(direction)
            }
            
            appDelegate().modeMap.activeModeDirection = .no_DIRECTION
            
    //        let actionnNme = appDelegate().modeMap.selectedMode.actionNameInDirection(direction)
    //        appDelegate().hudController.toastActiveAction(actionName, direction: direction)
        })
    }
    
    func closeMenu() {
        fatalError("Need from Mac")
    }
    
    func resetPairingState() {
        pairingButtonState = TTButtonState()
    }
    
    func readBluetoothDataDuringPairing(_ data: Data) {
        let state = self.buttonDownStateFromData(data)
        pairingButtonState.north = pairingButtonState.north || (state & (1 << 0)) != 0x0
        pairingButtonState.east  = pairingButtonState.east  || (state & (1 << 1)) != 0x0
        pairingButtonState.west  = pairingButtonState.west  || (state & (1 << 2)) != 0x0
        pairingButtonState.south = pairingButtonState.south || (state & (1 << 3)) != 0x0
        pairingActivatedCount = NSNumber(value: pairingButtonState.activatedCount() as Int)
        
        if (state & (1 << 0)) == (1 << 0) {
            appDelegate().modeMap.activeModeDirection = .north
        } else if (state & (1 << 1)) == (1 << 1) {
            appDelegate().modeMap.activeModeDirection = .east
        } else if (state & (1 << 2)) == (1 << 2) {
            appDelegate().modeMap.activeModeDirection = .west
        } else if (state & (1 << 3)) == (1 << 3) {
            appDelegate().modeMap.activeModeDirection = .south
        } else {
            appDelegate().modeMap.activeModeDirection = .no_DIRECTION
        }
    }
    
    func isDevicePaired() -> Bool {
        return pairingActivatedCount.intValue == pairingButtonState.count
    }
    
    func isDirectionPaired(_ direction: TTModeDirection) -> Bool {
        switch direction {
        case .north:
            return pairingButtonState.north
        case .east:
            return pairingButtonState.east
        case .west:
            return pairingButtonState.west
        case .south:
            return pairingButtonState.south
        default:
            return false
        }
    }
    
}

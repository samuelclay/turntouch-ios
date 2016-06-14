//
//  TTButtonTimer.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import Foundation

enum TTPressState: Int {
    case Active = 0x01
    case Toggle = 0x02
    case Mode = 0x03
}

enum TTHUDMenuState {
    case Hidden
    case Active
}

let DOUBLE_CLICK_ACTION_DURATION = 0.5

class TTButtonTimer : NSObject {
    
    var activeModeTimer: NSTimer!
    var previousButtonState = TTButtonState()
    var pairingButtonState: TTButtonState!
    var lastButtonPressedDirection: TTModeDirection = .NO_DIRECTION
    var lastButtonPressStart: NSDate!
    var holdToastStart: NSDate!
    var menuHysteresis = false
    
    var pairingActivatedCount: NSNumber!
    var skipButtonActions = false
    var menuState: TTHUDMenuState = .Hidden
    
    func bytesFromData(data: NSData) -> [UInt8] {
        let count = data.length / sizeof(UInt8)
        var array = [UInt8](count: count, repeatedValue: 0)
        data.getBytes(&array, length: count * sizeof(UInt8))
        
        return array
    }
    
    func buttonDownStateFromData(data: NSData) -> UInt8 {
        let bytes = self.bytesFromData(data.subdataWithRange(NSRange(location: 0, length: 1)))
        return UInt8(~(bytes[0]) & 0xF)
    }
    
    func doubleStateFromData(data: NSData) -> UInt8 {
        let bytes = self.bytesFromData(data.subdataWithRange(NSRange(location: 0, length: 1)))
        let state = UInt8(~(bytes[0]) & 0xF0)
        return state >> 4
    }
    
    func heldStateFromData(data: NSData) -> Bool {
        let bytes = self.bytesFromData(data.subdataWithRange(NSRange(location: 1, length: 1)))
        return bytes[0] == 0xFF
    }
    
    func readBluetoothData(data: NSData) {
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
            menuState = .Hidden
            
            if state == 0x01 {
                // Don't fire action on button release
                previousButtonState.north = false
                self.activateMode(.NORTH)
            } else if state == 0x02 {
                previousButtonState.east = false
                self.activateMode(.EAST)
            } else if state == 0x04 {
                previousButtonState.west = false
                self.activateMode(.WEST)
            } else if state == 0x08 {
                previousButtonState.south = false
                self.activateMode(.SOUTH)
            }
            self.activateButton(.NO_DIRECTION)
        } else if anyButtonPressed {
//            print(" ---> Press down button \(previousButtonState.inMultitouch() ? "(multi-touch)" : "")")
            previousButtonState = latestButtonState
            
            if latestButtonState.inMultitouch() {
                if holdToastStart == nil && !menuHysteresis && menuState == .Hidden {
                    holdToastStart = NSDate()
                    menuHysteresis = true
                    menuState = .Active
//                    appDelegate().hudController.holdToastActiveMode(false)
                } else if menuState == .Active && !menuHysteresis {
                    menuHysteresis = true
                    menuState = .Hidden
                    self.releaseToastActiveMode()
                }
                self.activateButton(.NO_DIRECTION)
            } else if menuState == .Active {
                if (state & 0x01) == 0x01 {
                    self.fireMenuButton(.NORTH)
                } else if (state & 0x02) == 0x02 {
                    // Not on button down, wait for button up
                } else if (state & 0x08) == 0x08 {
                    self.fireMenuButton(.SOUTH)
                } else if state == 0x00 {
                    self.activateButton(.NO_DIRECTION)
                }
            } else {
                if (state & 0x01) == 0x01 {
                    self.activateButton(.NORTH)
                } else if (state & 0x02) == 0x02 {
                    self.activateButton(.EAST)
                } else if (state & 0x04) == 0x04 {
                    self.activateButton(.WEST)
                } else if (state & 0x08) == 0x08 {
                    self.activateButton(.SOUTH)
                } else if state == 0x00 {
                    self.activateButton(.NO_DIRECTION)
                }
            }
        } else if anyButtonLifted {
            // Press up button
            previousButtonState = latestButtonState
            var buttonPressedDirection: TTModeDirection!
            switch buttonLifted {
            case 0:
                buttonPressedDirection = .NORTH
            case 1:
                buttonPressedDirection = .EAST
            case 2:
                buttonPressedDirection = .WEST
            case 3:
                buttonPressedDirection = .SOUTH
            default:
                buttonPressedDirection = .NO_DIRECTION
            }
            
//            print(" ---> Lift button\(previousButtonState.inMultitouch() ? " (multi-touch)" : ""): \(buttonPressedDirection)")
            
            if menuState == .Active {
                if buttonPressedDirection == .NORTH {
                    // Fired on button down
                } else if buttonPressedDirection == .EAST {
                    self.fireMenuButton(.EAST)
                } else if buttonPressedDirection == .WEST {
                    self.fireMenuButton(.WEST)
                } else if state == 0x00 {
                    self.activateButton(.NO_DIRECTION)
                }
            } else if (doubleState == 0xF &&
                       lastButtonPressedDirection != .NO_DIRECTION &&
                       buttonPressedDirection == lastButtonPressedDirection &&
                       NSDate().timeIntervalSinceDate(lastButtonPressStart) < DOUBLE_CLICK_ACTION_DURATION) {
                // Double click detected
                self.fireDoubleButton(buttonPressedDirection)
                lastButtonPressedDirection = .NO_DIRECTION
                lastButtonPressStart = nil
            } else if doubleState != 0xF && doubleState != 0x0 {
                // Firmware v3 has hardware support for double-click
                self.fireDoubleButton(buttonPressedDirection)
            } else {
                lastButtonPressedDirection = buttonPressedDirection
                lastButtonPressStart = NSDate()
                
                self.fireButton(buttonPressedDirection)
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(DOUBLE_CLICK_ACTION_DURATION * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), {
                    self.lastButtonPressStart = nil
                    self.lastButtonPressedDirection = .NO_DIRECTION
                })
            }
        } else if !latestButtonState.anyPressedDown() {
            let inMultitouch = previousButtonState.inMultitouch()
            previousButtonState = latestButtonState
            
            if !inMultitouch && buttonLifted >= 0 && menuHysteresis {
                self.releaseToastActiveMode()
            } else if menuState == .Hidden {
                self.releaseToastActiveMode()
            }
            self.activateButton(.NO_DIRECTION)
            menuHysteresis = false
            holdToastStart = nil
        }
    }
    
    func releaseToastActiveMode() {
//        appDelegate().hudController.releaseToastActiveMode()
        
        holdToastStart = nil
    }
    
    func activateMode(direction: TTModeDirection) {
        dispatch_async(dispatch_get_main_queue(), {
            appDelegate().modeMap.activeModeDirection = .NO_DIRECTION
            appDelegate().modeMap.selectedModeDirection = direction
            
    //        appDelegate().hudController.holdToastActiveMode(true)
        })
    }
    
    func activateButton(direction: TTModeDirection) {
        dispatch_async(dispatch_get_main_queue(), {
            appDelegate().modeMap.activeModeDirection = direction
            
    //        let actionnNme = appDelegate().modeMap.selectedMode.actionNameInDirection(direction)
    //        appDelegate().hudController.holdToastActiveAction(actionName, direction: direction)
            
            if direction != .NO_DIRECTION {
                // Mac has a timer here that shows the HUD. May not be necessary on iOS
            }
        })
    }
    
    func fireMenuButton(direction: TTModeDirection) {
        dispatch_async(dispatch_get_main_queue(), {
//        appDelegate().hudController.modeHUDController.runDirection(direction)
        })
    }
    
    func fireButton(direction: TTModeDirection) {
        dispatch_async(dispatch_get_main_queue(), {
            appDelegate().modeMap.activeModeDirection = direction
            if !self.skipButtonActions {
                appDelegate().modeMap.runActiveButton()
            }
            appDelegate().modeMap.activeModeDirection = .NO_DIRECTION
            
    //        let actionnNme = appDelegate().modeMap.selectedMode.actionNameInDirection(direction)
    //        appDelegate().hudController.toastActiveAction(actionName, direction: direction)
        })
    }
    
    func fireDoubleButton(direction: TTModeDirection) {
        dispatch_async(dispatch_get_main_queue(), {
            if direction == .NO_DIRECTION {
                return
            }
            
            if !self.skipButtonActions {
                appDelegate().modeMap.runDoubleButton(direction)
            }
            
            appDelegate().modeMap.activeModeDirection = .NO_DIRECTION
            
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
    
    func readBluetoothDataDuringPairing(data: NSData) {
        let state = self.buttonDownStateFromData(data)
        pairingButtonState.north = pairingButtonState.north || (state & (1 << 0)) != 0x0
        pairingButtonState.east  = pairingButtonState.east  || (state & (1 << 1)) != 0x0
        pairingButtonState.west  = pairingButtonState.west  || (state & (1 << 2)) != 0x0
        pairingButtonState.south = pairingButtonState.south || (state & (1 << 3)) != 0x0
        pairingActivatedCount = NSNumber(integer: pairingButtonState.activatedCount())
        
        if (state & (1 << 0)) == (1 << 0) {
            appDelegate().modeMap.activeModeDirection = .NORTH
        } else if (state & (1 << 1)) == (1 << 1) {
            appDelegate().modeMap.activeModeDirection = .EAST
        } else if (state & (1 << 2)) == (1 << 2) {
            appDelegate().modeMap.activeModeDirection = .WEST
        } else if (state & (1 << 3)) == (1 << 3) {
            appDelegate().modeMap.activeModeDirection = .SOUTH
        } else {
            appDelegate().modeMap.activeModeDirection = .NO_DIRECTION
        }
    }
    
    func isDevicePaired() -> Bool {
        return pairingActivatedCount.integerValue == pairingButtonState.count
    }
    
    func isDirectionPaired(direction: TTModeDirection) -> Bool {
        switch direction {
        case .NORTH:
            return pairingButtonState.north
        case .EAST:
            return pairingButtonState.east
        case .WEST:
            return pairingButtonState.west
        case .SOUTH:
            return pairingButtonState.south
        default:
            return false
        }
    }
    
}
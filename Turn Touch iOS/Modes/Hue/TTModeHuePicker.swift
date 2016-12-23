//
//  TTModeHuePicker.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/24/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

class TTModeHuePicker: TTOptionsDetailViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, TTPickerViewControllerDelegate  {
    var pickerVC: TTPickerViewController!
    var popoverController: UIPopoverPresentationController?
    var presented = false
    
    @IBOutlet var roomPicker: UITextField!
    @IBOutlet var singlePicker: UITextField?
    @IBOutlet var doublePicker: UITextField?
    
    var scenes: [[String: String]] = []
    var rooms: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.drawScenes()
    }
    
    func drawScenes() {
        roomPicker.delegate = self
        singlePicker?.delegate = self
        doublePicker?.delegate = self
                
        let modeHue = self.mode as! TTModeHue
        modeHue.ensureRoomSelected(in: self.action.direction)
        modeHue.ensureScenesSelected()
        
        var roomSelected = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String
        var sceneSelected = self.action.optionValue(TTModeHueConstants.kHueScene) as? String
        var doubleSceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene) as? String
        
        let cache = TTModeHue.hueSdk.resourceCache
        
        guard let hueScenes = cache?.scenes, let hueRooms = cache?.groups else {
            print(" ---> Hue options not ready yet, no scenes or groups: \(cache?.scenes) / \(cache?.groups)")
            return
        }
        
        if roomSelected == nil {
            for (_, room) in hueRooms {
                roomSelected = room.identifier
                self.action.changeActionOption(TTModeHueConstants.kHueRoom, to: roomSelected!)
                break
            }
        }
        
        if sceneSelected == nil {
            for (_, room) in hueRooms {
                sceneSelected = "TT-ee-1-room-\(room.identifier)"
                self.action.changeActionOption(TTModeHueConstants.kHueScene, to: sceneSelected!)
                break
            }
        }
        if doubleSceneSelected == nil {
            for (_, room) in hueRooms {
                doubleSceneSelected = "TT-ee-2-room-\(room.identifier)"
                self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: doubleSceneSelected!)
                break
            }
        }
        
        var roomLights: [String] = []
        rooms = []
        for (_, room) in hueRooms {
            rooms.append(["name": room.name, "identifier": room.identifier])
            if roomSelected == room.identifier {
                roomPicker.text = room.name
                roomLights = room.lightIdentifiers!
            }
        }
        
        rooms = rooms.sorted {
            (a, b) -> Bool in
            return a["name"] < b["name"]
        }
        
        scenes = []
        for (_, scene) in hueScenes {
            // Check if any light in scene in is room
            var sceneInRoom = false
            for sceneLight in scene.lightIdentifiers! {
                if roomLights.contains(sceneLight) {
                    sceneInRoom = true
                    break
                }
            }
            
            if !sceneInRoom {
                print(" ---> (\(hueScenes.count) scenes) Tossing scene \(scene.name) \(scene.identifier) because \(roomLights) aren't in \(scene.lightIdentifiers!)")
                continue
            }
            print(" ---> (\(hueScenes.count) scenes) Keeping scene \(scene.name) \(scene.identifier) because \(roomLights) are in \(scene.lightIdentifiers!)")

            
            scenes.append(["name": scene.name, "identifier": scene.identifier])
            if sceneSelected == scene.identifier {
                singlePicker?.text = scene.name
            }
            if doubleSceneSelected == scene.identifier {
                doublePicker?.text = scene.name
            }
        }
        
        scenes = scenes.sorted {
            (a, b) -> Bool in
            return a["name"] < b["name"]
        }
        
    }
    
    func pickerDismissed(_ row: Int, textField: UITextField) {
        presented = false
        if rooms.count == 0 {
            return
        }
        
        if textField == roomPicker {
            let room = rooms[row]
            
            textField.text = room["name"]
            
            if let identifier = room["identifier"] {
                self.action.changeActionOption(TTModeHueConstants.kHueRoom, to: identifier)
            }
        } else if scenes.count > row {
            let scene = scenes[row]
            
            textField.text = scene["name"]
            
            if let identifier = scene["identifier"] {
                if textField == singlePicker {
                    self.action.changeActionOption(TTModeHueConstants.kHueScene, to: identifier)
                } else if textField == doublePicker {
                    self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: identifier)
                }
            }
        }
        
        self.drawScenes()
    }

    // MARK: Text Field delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if presented {
            return false
        }
        
        pickerVC = TTPickerViewController()
        pickerVC.delegate = self
        pickerVC.textField = textField
        pickerVC.modalPresentationStyle = .popover
        pickerVC.preferredContentSize = CGSize(width: 240, height: 180)
        pickerVC.picker.delegate = self
        
        popoverController = pickerVC.popoverPresentationController
        if let popover = popoverController {
            popover.sourceView = textField
            popover.sourceRect = CGRect(origin: CGPoint(x: textField.bounds.midX, y: -8), size: CGSize.zero)
            popover.delegate = self
            popover.permittedArrowDirections = [.up, .down]
            self.present(pickerVC, animated: true, completion: nil)
            presented = true
            
            var currentRow: Int = 0
            var sceneSelected: String?
            var roomSelected: String?
            
            if textField == roomPicker {
                roomSelected = self.action.optionValue(TTModeHueConstants.kHueRoom) as? String
                for (i, room) in rooms.enumerated() {
                    if room["identifier"] == roomSelected {
                        currentRow = i
                        break
                    }
                }
            } else {
                if textField == singlePicker {
                    sceneSelected = self.action.optionValue(TTModeHueConstants.kHueScene) as? String
                } else if textField == doublePicker {
                    sceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene) as? String
                }
                for (i, scene) in scenes.enumerated() {
                    if scene["identifier"] == sceneSelected {
                        currentRow = i
                        break
                    }
                }
            }
            
            pickerVC.picker.selectRow(currentRow, inComponent: 0, animated: true)
        }
        
        return false
    }
    
    // MARK: - Delegates and data sources
    
    func adaptivePresentationStyle(for controller: UIPresentationController)
        -> UIModalPresentationStyle {
            return .none
    }
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerVC.textField == roomPicker {
            return rooms.count
        } else {
            return scenes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerVC.textField == roomPicker {
            return rooms[row]["name"]
        } else {
            return scenes[row]["name"]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if rooms.count == 0 {
            return
        }
        
        if pickerVC.textField == roomPicker {
            self.action.changeActionOption(TTModeHueConstants.kHueRoom, to: rooms[row]["identifier"]!)
            self.action.removeActionOption(TTModeHueConstants.kHueScene)
            self.action.removeActionOption(TTModeHueConstants.kDoubleTapHueScene)
        } else if pickerVC.textField == singlePicker {
            self.action.changeActionOption(TTModeHueConstants.kHueScene, to: scenes[row]["identifier"]!)
        } else if pickerVC.textField == doublePicker {
            self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: scenes[row]["identifier"]!)
        }
        
        self.drawScenes()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerVC.textField == roomPicker ? rooms[row]["name"] : scenes[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blue])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            if pickerVC.textField == singlePicker || pickerVC.textField == doublePicker {
                let hue = CGFloat(row)/CGFloat(scenes.count)
                pickerLabel?.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            }
        }
        let titleData = pickerVC.textField == roomPicker ? rooms[row]["name"] : scenes[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }

}

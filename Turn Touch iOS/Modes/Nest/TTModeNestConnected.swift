//
//  TTModeNestConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 1/3/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNestConnected: TTOptionsDetailViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, TTPickerViewControllerDelegate, TTModeNestDelegate {
    
    var modeNest: TTModeNest!
    
    var pickerVC: TTPickerViewController!
    var popoverController: UIPopoverPresentationController?
    var textField: UITextField!
    var presented = false
    
    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    @IBOutlet var singlePicker: UITextField!
    //    @IBOutlet var doublePicker: UITextField!
    
    var devices: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.modeNest = self.mode as! TTModeNest
        self.modeNest.delegate = self
        singlePicker.delegate = self
        //        doublePicker.delegate = self
        
        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })
        
        self.selectDevice()
    }
    
    func selectDevice() {
        devices = []
        pickerVC?.picker.reloadAllComponents()
        var deviceSelected = self.mode.modeOptionValue(TTModeNestConstants.kNestThermostatIdentifier,
                                                       modeDirection: appDelegate().modeMap.selectedModeDirection) as? String
        //        var doubleSceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene,
        //                                                          direction: appDelegate().modeMap.inspectingModeDirection) as? String
        
//        let nestDevices = modeNest.foundDevices()
//        for device in nestDevices {
//            devices.append(["name": device.name!, "identifier": device.uuid!])
//            if deviceSelected == device.uuid {
//                singlePicker.text = device.name
//            }
//        }
//        
//        if deviceSelected == nil && devices.count > 0 {
//            singlePicker.text = devices[0]["name"]
//            deviceSelected = devices[0]["identifier"]
//        }
    }
    
    func pickerDismissed(_ row: Int, textField: UITextField) {
        presented = false
        if row >= devices.count {
            return
        }
        
        let device = devices[row]
        
        textField.text = device["name"]
        
        if let identifier = device["identifier"] {
            if textField == singlePicker {
                self.mode.changeModeOption(TTModeNestConstants.kNestThermostatIdentifier, to: identifier as AnyObject)
                //            } else if textField == doublePicker {
                //                self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: identifier)
            }
        }
    }
    
    @IBAction func refreshDevices(_ sender: AnyObject) {
        spinner.forEach({ $0.isHidden = false })
        refreshButton.forEach({ $0.isHidden = true })
        spinner.forEach { (s) in
            s.startAnimating()
        }
        
        self.modeNest.beginConnectingToNest()
    }
    
    func changeState(_ state: TTNestState, mode: TTModeNest) {
        if state == .connected {
            spinner.forEach({ $0.isHidden = true })
            refreshButton.forEach({ $0.isHidden = false })
        }
        self.selectDevice()
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
            
            var deviceSelected: String?
            if textField == singlePicker {
                deviceSelected = self.mode.modeOptionValue(TTModeNestConstants.kNestThermostatIdentifier,
                                                           modeDirection: appDelegate().modeMap.selectedModeDirection) as? String
                //            } else if textField == doublePicker {
                //                sceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene,
                //                                                        direction: appDelegate().modeMap.inspectingModeDirection) as? String
            }
            var currentRow: Int = 0
            for (i, device) in devices.enumerated() {
                if device["identifier"] == deviceSelected {
                    currentRow = i
                    break
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
        return devices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return devices[row]["name"]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == singlePicker {
            self.mode.changeModeOption(TTModeNestConstants.kNestThermostatIdentifier, to: devices[row]["identifier"] as AnyObject)
            //        } else if pickerView == doublePicker {
            //            self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: scenes[row]["identifier"]!)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = devices[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blue])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(row)/CGFloat(devices.count)
            pickerLabel?.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = devices[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
}
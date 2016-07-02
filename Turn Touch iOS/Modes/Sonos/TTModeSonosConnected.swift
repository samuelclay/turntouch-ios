//
//  TTModeSonosConnected.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/29/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeSonosConnected: TTOptionsDetailViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, TTPickerViewControllerDelegate, TTModeSonosDelegate {
    
    var modeSonos: TTModeSonos!
    
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
        
        self.modeSonos = self.mode as! TTModeSonos
        self.modeSonos.delegate = self
        singlePicker.delegate = self
        //        doublePicker.delegate = self
        
        spinner.forEach({ $0.hidden = true })
        refreshButton.forEach({ $0.hidden = false })
        
        self.selectDevice()
    }
    
    func selectDevice() {
        devices = []
        pickerVC?.picker.reloadAllComponents()
        var deviceSelected = self.mode.modeOptionValue(TTModeSonosConstants.kSonosDeviceId,
                                                       modeDirection: appDelegate().modeMap.selectedModeDirection) as? String
        //        var doubleSceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene,
        //                                                          direction: appDelegate().modeMap.inspectingModeDirection) as? String
        
        let sonosDevices = modeSonos.foundDevices()
        for device in sonosDevices {
            devices.append(["name": device.name, "identifier": device.uuid])
            if deviceSelected == device.uuid {
                singlePicker.text = device.name
            }
        }
        
        if deviceSelected == nil && devices.count > 0 {
            singlePicker.text = devices[0]["name"]
            deviceSelected = devices[0]["identifier"]
        }
    }
    
    func pickerDismissed(row: Int, textField: UITextField) {
        presented = false
        if row >= devices.count {
            return
        }
        
        let device = devices[row]
        
        textField.text = device["name"]
        
        if let identifier = device["identifier"] {
            if textField == singlePicker {
                self.mode.changeModeOption(TTModeSonosConstants.kSonosDeviceId, to: identifier)
                //            } else if textField == doublePicker {
                //                self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: identifier)
            }
        }
    }
    
    @IBAction func refreshDevices(sender: AnyObject) {
        spinner.forEach({ $0.hidden = false })
        refreshButton.forEach({ $0.hidden = true })
        spinner.forEach { (s) in
            s.startAnimating()
        }
        
        self.modeSonos.beginConnectingToSonos()
    }
    
    func changeState(state: TTSonosState, mode: TTModeSonos) {
        if state == .Connected {
            spinner.forEach({ $0.hidden = true })
            refreshButton.forEach({ $0.hidden = false })
        }
        self.selectDevice()
    }
    
    // MARK: Text Field delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if presented {
            return false
        }
        
        pickerVC = TTPickerViewController()
        pickerVC.delegate = self
        pickerVC.textField = textField
        pickerVC.modalPresentationStyle = .Popover
        pickerVC.preferredContentSize = CGSize(width: 240, height: 180)
        pickerVC.picker.delegate = self
        
        popoverController = pickerVC.popoverPresentationController
        if let popover = popoverController {
            popover.sourceView = textField
            popover.sourceRect = CGRect(origin: CGPoint(x: CGRectGetMidX(textField.bounds), y: -8), size: CGSize.zero)
            popover.delegate = self
            popover.permittedArrowDirections = [.Up, .Down]
            self.presentViewController(pickerVC, animated: true, completion: nil)
            presented = true
            
            var deviceSelected: String?
            if textField == singlePicker {
                deviceSelected = self.mode.modeOptionValue(TTModeSonosConstants.kSonosDeviceId,
                                                           modeDirection: appDelegate().modeMap.selectedModeDirection) as? String
                //            } else if textField == doublePicker {
                //                sceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene,
                //                                                        direction: appDelegate().modeMap.inspectingModeDirection) as? String
            }
            var currentRow: Int = 0
            for (i, device) in devices.enumerate() {
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController)
        -> UIModalPresentationStyle {
            return .None
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return devices.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return devices[row]["name"]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == singlePicker {
            self.mode.changeModeOption(TTModeSonosConstants.kSonosDeviceId, to: devices[row]["identifier"]!)
            //        } else if pickerView == doublePicker {
            //            self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: scenes[row]["identifier"]!)
        }
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = devices[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(row)/CGFloat(devices.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = devices[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .Center
        
        return pickerLabel
        
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
}

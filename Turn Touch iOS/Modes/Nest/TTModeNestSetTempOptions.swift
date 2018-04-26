//
//  TTModeNestSetTempOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/1/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNestSetTempOptions: TTOptionsDetailViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, TTPickerViewControllerDelegate {
    
    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    @IBOutlet var tempSlider: UISlider!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var singlePicker: UITextField!

    var modeNest: TTModeNest!

    var pickerVC: TTPickerViewController!
    var popoverController: UIPopoverPresentationController?
    var textField: UITextField!
    var presented = false
    
    var devices: [[String: String]] = []

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeNestSetTempOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.modeNest = self.mode as! TTModeNest
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        singlePicker.delegate = self
        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })

        self.selectDevice()
        self.updateLabel()
        
        let temp = self.action.optionValue(TTModeNestConstants.kNestSetTemperature) as! Int
        tempSlider.value = Float(temp)
    }
    
    // MARK: Temperature Slider
    
    func updateLabel() {
        let thermostat = self.modeNest.selectedThermostat()
        let temp = self.action.optionValue(TTModeNestConstants.kNestSetTemperature)
        let isCelsius = thermostat?.temperatureScale == .C
        let scale = isCelsius ? "C" : "F"

        tempLabel.text = "\(temp!)°\(scale)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeSlider(sender: UISlider) {
        let temp = Int(round(tempSlider.value))
        self.action.changeActionOption(TTModeNestConstants.kNestSetTemperature, to: temp)
        
        self.updateLabel()
    }

    
    // MARK: Thermostat Picker
    
    func selectDevice() {
        devices = []
        pickerVC?.picker.reloadAllComponents()
        var deviceSelected = self.mode.modeOptionValue(TTModeNestConstants.kNestThermostatIdentifier) as? String
        
        for (_, thermostat) in TTModeNest.thermostats {
            devices.append(["name": thermostat.name, "identifier": thermostat.deviceId])
            if deviceSelected == thermostat.deviceId {
                singlePicker.text = thermostat.name
            }
        }
        
        if deviceSelected == nil && devices.count > 0 {
            singlePicker.text = devices[0]["name"]
            deviceSelected = devices[0]["identifier"]
        }
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
            }
        }
    }
    
    @IBAction func refreshDevices(_ sender: AnyObject) {
        spinner.forEach({ $0.isHidden = false })
        refreshButton.forEach({ $0.isHidden = true })
        spinner.forEach { (s) in
            s.startAnimating()
        }
        
        self.modeNest.authorizeNest()
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
        pickerVC.picker.dataSource = self
        
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
                deviceSelected = self.mode.modeOptionValue(TTModeNestConstants.kNestThermostatIdentifier) as? String
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
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
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSAttributedStringKey.font:UIFont(name: "Effra", size: 18.0)!,NSAttributedStringKey.foregroundColor:UIColor.blue])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(row)/CGFloat(devices.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = devices[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSAttributedStringKey.font:UIFont(name: "Effra", size: 18.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        
        return pickerLabel
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
}

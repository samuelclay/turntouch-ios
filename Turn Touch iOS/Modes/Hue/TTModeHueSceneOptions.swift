//
//  TTModeHueSceneOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/16/16.
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


class TTModeHueSceneOptions: TTOptionsDetailViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, TTPickerViewControllerDelegate {

//    typealias pickerCallback = (row: Int, forTextField: UITextField) -> ()

    var pickerVC: TTPickerViewController!
    var popoverController: UIPopoverPresentationController?
    var textField: UITextField!
    var presented = false

    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    @IBOutlet var singlePicker: UITextField!
    @IBOutlet var doublePicker: UITextField!
    
    var scenes: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.drawScenes()
    }
    
    func drawScenes() {
        singlePicker.delegate = self
        doublePicker.delegate = self
        
        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })
        
        var sceneSelected = self.action.optionValue(TTModeHueConstants.kHueScene,
                                                    direction: appDelegate().modeMap.inspectingModeDirection) as? String
        var doubleSceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene,
                                                          direction: appDelegate().modeMap.inspectingModeDirection) as? String

        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        
        if cache?.scenes == nil {
            return
        }
        
        if sceneSelected == nil {
            switch self.action.actionName {
            case "TTModeHueSceneEarlyEvening":
                sceneSelected = "TT-ee-1"
            case "TTModeHueSceneLateEvening":
                sceneSelected = "TT-le-1"
            default:
                sceneSelected = "TT-ee-1"
            }
            self.action.changeActionOption(TTModeHueConstants.kHueScene, to: sceneSelected!)
        }
        if doubleSceneSelected == nil {
            switch self.action.actionName {
            case "TTModeHueSceneEarlyEvening":
                doubleSceneSelected = "TT-ee-2"
            case "TTModeHueSceneLateEvening":
                doubleSceneSelected = "TT-le-2"
            default:
                doubleSceneSelected = "TT-ee-2"
            }
            self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: doubleSceneSelected!)
        }
        
        scenes = []
        for (_, s) in (cache?.scenes)! {
            let scene = s as! PHScene
            scenes.append(["name": scene.name, "identifier": scene.identifier])
            if sceneSelected == scene.identifier {
                singlePicker.text = scene.name
            }
            if doubleSceneSelected == scene.identifier {
                doublePicker.text = scene.name
            }
        }
        
        scenes = scenes.sorted {
            (a, b) -> Bool in
            return a["name"] < b["name"]
        }
    }
    
    func pickerDismissed(_ row: Int, textField: UITextField) {
        presented = false
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
    
    @IBAction func refreshScenes(_ sender: AnyObject) {
        spinner.forEach({ $0.isHidden = false })
        refreshButton.forEach({ $0.isHidden = true })
        spinner.forEach { (s) in
            s.startAnimating()
        }

        let bridgeSendApi = PHBridgeSendAPI()
        bridgeSendApi.getAllScenes { (dictionary, errors) in
            self.drawScenes()
        }
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
            
            var sceneSelected: String?
            if textField == singlePicker {
                sceneSelected = self.action.optionValue(TTModeHueConstants.kHueScene,
                                                        direction: appDelegate().modeMap.inspectingModeDirection) as? String
            } else if textField == doublePicker {
                sceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene,
                                                        direction: appDelegate().modeMap.inspectingModeDirection) as? String
            }
            var currentRow: Int = 0
            for (i, scene) in scenes.enumerated() {
                if scene["identifier"] == sceneSelected {
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
        return scenes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return scenes[row]["name"]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == singlePicker {
            self.action.changeActionOption(TTModeHueConstants.kHueScene, to: scenes[row]["identifier"]!)
        } else if pickerView == doublePicker {
            self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: scenes[row]["identifier"]!)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = scenes[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blue])
        return myTitle
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(row)/CGFloat(scenes.count)
            pickerLabel?.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = scenes[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
}

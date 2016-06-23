//
//  TTModeHueSceneOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/16/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTModeHueSceneOptions: TTOptionsDetailViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, ScenePickerViewControllerDelegate {

    typealias ScenePickerCallback = (scene: String, forTextField: UITextField) -> ()

    var scenePickerVC: TTModeHueScenePickerViewController!
    var scenePopover: UIPopoverPresentationController?
    var textField: UITextField!
    var presented = false

    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!
    @IBOutlet var singlePicker: UITextField!
    @IBOutlet var doublePicker: UITextField!
    
    var scenes: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singlePicker.delegate = self
        doublePicker.delegate = self
        
        spinner.forEach({ $0.hidden = true })
        refreshButton.forEach({ $0.hidden = false })
        
        var sceneSelected = self.action.optionValue(TTModeHueConstants.kHueScene,
                                                    direction: appDelegate().modeMap.inspectingModeDirection) as? String
        var doubleSceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene,
                                                          direction: appDelegate().modeMap.inspectingModeDirection) as? String

        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        
        if cache.scenes == nil {
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
        
        for (_, s) in cache.scenes {
            let scene = s as! PHScene
            scenes.append(["name": scene.name, "identifier": scene.identifier])
            if sceneSelected == scene.identifier {
                singlePicker.text = scene.name
            }
            if doubleSceneSelected == scene.identifier {
                doublePicker.text = scene.name
            }
        }
        
        scenes = scenes.sort {
            (a, b) -> Bool in
            return a["name"] < b["name"]
        }
    }
    
    func scenePickerDismissed(sceneRow: Int, textField: UITextField) {
        presented = false
        let scene = scenes[sceneRow]
        
        textField.text = scene["name"]
        
        if let identifier = scene["identifier"] {
            if textField == singlePicker {
                self.action.changeActionOption(TTModeHueConstants.kHueScene, to: identifier)
            } else if textField == doublePicker {
                self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: identifier)
            }
        }
    }
    
    @IBAction func refreshScenes(sender: AnyObject) {
        spinner.forEach({ $0.hidden = false })
        refreshButton.forEach({ $0.hidden = true })
    }
    
    // MARK: Text Field delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if presented {
            return false
        }
        
        scenePickerVC = TTModeHueScenePickerViewController()
        scenePickerVC.delegate = self
        scenePickerVC.textField = textField
        scenePickerVC.modalPresentationStyle = .Popover
        scenePickerVC.preferredContentSize = CGSize(width: 240, height: 180)
        scenePickerVC.scenePicker.delegate = self
        
        scenePopover = scenePickerVC.popoverPresentationController
        if let popover = scenePopover {
            popover.sourceView = textField
            popover.sourceRect = CGRect(origin: CGPoint(x: CGRectGetMidX(textField.bounds), y: -8), size: CGSize.zero)
            popover.delegate = self
            popover.permittedArrowDirections = [.Up, .Down]
            self.presentViewController(scenePickerVC, animated: true, completion: nil)
            presented = true
            
            var sceneSelected: String?
            if textField == singlePicker {
                sceneSelected = self.action.optionValue(TTModeHueConstants.kHueScene,
                                                        direction: appDelegate().modeMap.inspectingModeDirection) as? String
            } else if textField == doublePicker {
                sceneSelected = self.action.optionValue(TTModeHueConstants.kDoubleTapHueScene,
                                                        direction: appDelegate().modeMap.inspectingModeDirection) as? String
            }
            var currentSceneRow: Int = 0
            for (i, scene) in scenes.enumerate() {
                if scene["identifier"] == sceneSelected {
                    currentSceneRow = i
                    break
                }
            }
            scenePickerVC.scenePicker.selectRow(currentSceneRow, inComponent: 0, animated: true)
        }

        return false
    }
    
    //MARK: - Delegates and data sources
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController)
        -> UIModalPresentationStyle {
            return .None
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return scenes.count
    }
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return scenes[row]["name"]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == singlePicker {
            self.action.changeActionOption(TTModeHueConstants.kHueScene, to: scenes[row]["identifier"]!)
        } else if pickerView == doublePicker {
            self.action.changeActionOption(TTModeHueConstants.kDoubleTapHueScene, to: scenes[row]["identifier"]!)
        }
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = scenes[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    /* less conservative memory version
     func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
     let pickerLabel = UILabel()
     let titleData = scenes[row]
     let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
     pickerLabel.attributedText = myTitle
     //color  and center the label's background
     let hue = CGFloat(row)/CGFloat(scenes.count)
     pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness:1.0, alpha: 1.0)
     pickerLabel.textAlignment = .Center
     return pickerLabel
     }
     */
    
    /* better memory management version */
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            let hue = CGFloat(row)/CGFloat(scenes.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = scenes[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSFontAttributeName:UIFont(name: "Effra", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .Center
        
        return pickerLabel
        
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    // for best use with multitasking , dont use a constant here.
    //this is for demonstration purposes only.
//    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return 200
//    }
    
    
}

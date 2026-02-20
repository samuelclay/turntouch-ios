//
//  TTModeNanoleafSceneCustomOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit

class TTModeNanoleafSceneCustomOptions: TTOptionsDetailViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, TTPickerViewControllerDelegate {

    var pickerVC: TTPickerViewController!
    var popoverController: UIPopoverPresentationController?
    var presented = false

    @IBOutlet var singlePicker: UITextField!
    @IBOutlet var doublePicker: UITextField!
    @IBOutlet var spinner: [UIActivityIndicatorView]!
    @IBOutlet var refreshButton: [UIButton]!

    var effects: [[String: String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawEffects()
    }

    func drawEffects() {
        singlePicker.delegate = self
        doublePicker.delegate = self

        spinner.forEach({ $0.isHidden = true })
        refreshButton.forEach({ $0.isHidden = false })

        let cachedEffects = TTModeNanoleaf.cachedEffects
        effects = cachedEffects.map { ["name": $0, "identifier": $0] }

        let singleScene = self.action.optionValue(TTModeNanoleafConstants.kNanoleafScene) as? String
        let doubleScene = self.action.optionValue(TTModeNanoleafConstants.kDoubleTapNanoleafScene) as? String

        singlePicker.text = singleScene ?? (effects.first?["name"] ?? "")
        doublePicker.text = doubleScene ?? (effects.first?["name"] ?? "")

        // Auto-assign defaults if nil
        if singleScene == nil, let first = effects.first?["name"] {
            self.action.changeActionOption(TTModeNanoleafConstants.kNanoleafScene, to: first)
        }
        if doubleScene == nil, let first = effects.first?["name"] {
            self.action.changeActionOption(TTModeNanoleafConstants.kDoubleTapNanoleafScene, to: first)
        }

        appDelegate().mainViewController.actionDiamondView.redraw()
        appDelegate().mainViewController.actionTitleView.setNeedsDisplay()
    }

    @IBAction func refreshEffects(_ sender: AnyObject) {
        spinner.forEach({ $0.isHidden = false })
        refreshButton.forEach({ $0.isHidden = true })
        spinner.forEach { $0.startAnimating() }

        let modeNanoleaf = self.mode as! TTModeNanoleaf

        Task {
            do {
                let newEffects = try await modeNanoleaf.fetchEffects()
                await MainActor.run {
                    TTModeNanoleaf.cachedEffects = newEffects
                    self.drawEffects()
                }
            } catch {
                await MainActor.run {
                    self.drawEffects()
                }
                print(" ---> Nanoleaf refresh effects error: \(error)")
            }
        }
    }

    func pickerDismissed(_ row: Int, textField: UITextField) {
        presented = false
        guard row < effects.count else { return }

        let effect = effects[row]
        textField.text = effect["name"]

        if let identifier = effect["identifier"] {
            if textField == singlePicker {
                self.action.changeActionOption(TTModeNanoleafConstants.kNanoleafScene, to: identifier)
            } else if textField == doublePicker {
                self.action.changeActionOption(TTModeNanoleafConstants.kDoubleTapNanoleafScene, to: identifier)
            }
        }

        self.drawEffects()
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

            var currentRow: Int = 0
            let sceneKey = textField == singlePicker ? TTModeNanoleafConstants.kNanoleafScene : TTModeNanoleafConstants.kDoubleTapNanoleafScene
            let selected = self.action.optionValue(sceneKey) as? String
            for (i, effect) in effects.enumerated() {
                if effect["identifier"] == selected {
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
        return effects.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return effects[row]["name"]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < effects.count else { return }

        if pickerVC.textField == singlePicker {
            self.action.changeActionOption(TTModeNanoleafConstants.kNanoleafScene, to: effects[row]["identifier"]!)
        } else if pickerVC.textField == doublePicker {
            self.action.changeActionOption(TTModeNanoleafConstants.kDoubleTapNanoleafScene, to: effects[row]["identifier"]!)
        }

        self.drawEffects()
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel
        if let view = view {
            pickerLabel = view as! UILabel
        } else {
            pickerLabel = UILabel()
            let hue = CGFloat(row) / CGFloat(max(effects.count, 1))
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = effects[row]["name"]
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSAttributedString.Key.font: UIFont(name: "Effra", size: 18.0)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center

        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
}

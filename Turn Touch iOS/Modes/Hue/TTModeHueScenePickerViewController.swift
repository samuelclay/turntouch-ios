//
//  TTModeHueScenePickerViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit


protocol ScenePickerViewControllerDelegate : class {
    func scenePickerDismissed(sceneRow : Int, textField: UITextField)
}

class TTModeHueScenePickerViewController: UIViewController {

    @IBOutlet var container: UIView!
    @IBOutlet var scenePicker: UIPickerView!
    var textField: UITextField!
    weak var delegate: ScenePickerViewControllerDelegate?
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        scenePicker = UIPickerView()
        self.view.addSubview(scenePicker)
        self.view.addConstraint(NSLayoutConstraint(item: scenePicker, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scenePicker, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scenePicker, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scenePicker, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        let selectedRow = scenePicker.selectedRowInComponent(0)
        
        self.delegate?.scenePickerDismissed(selectedRow, textField: textField)
    }
    
}

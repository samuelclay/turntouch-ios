//
//  TTPickerViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit


protocol TTPickerViewControllerDelegate : class {
    func pickerDismissed(row : Int, textField: UITextField)
}

class TTPickerViewController: UIViewController {

    @IBOutlet var container: UIView!
    @IBOutlet var picker: UIPickerView!
    var textField: UITextField!
    weak var delegate: TTPickerViewControllerDelegate?
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(picker)
        self.view.addConstraint(NSLayoutConstraint(item: picker, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: picker, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: picker, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: picker, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        let selectedRow = picker.selectedRowInComponent(0)
        
        self.delegate?.pickerDismissed(selectedRow, textField: textField)
    }
    
}

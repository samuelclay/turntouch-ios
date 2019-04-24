//
//  TTPickerViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/17/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit


protocol TTPickerViewControllerDelegate : class {
    func pickerDismissed(_ row : Int, textField: UITextField)
}

class TTPickerViewController: UIViewController {

    @IBOutlet var container: UIView!
    @IBOutlet var picker: UIPickerView!
    var textField: UITextField!
    weak var delegate: TTPickerViewControllerDelegate?
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(picker)
        
        guard let picker = picker else {
            return
        }
        
        self.view.addConstraint(NSLayoutConstraint(item: picker, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: picker, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: picker, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let selectedRow = picker.selectedRow(inComponent: 0)
        
        self.delegate?.pickerDismissed(selectedRow, textField: textField)
    }
    
}

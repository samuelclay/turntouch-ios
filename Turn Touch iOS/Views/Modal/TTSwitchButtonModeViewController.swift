//
//  TTSwitchButtonModeViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/22/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import UIKit

class TTSwitchButtonModeViewController: UIViewController {

    @IBOutlet weak var fourAppSwitch: UISwitch!
    @IBOutlet weak var oneAppSwitch: UISwitch!
    @IBOutlet weak var performActionsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self, action: #selector(self.done))
        self.navigationItem.rightBarButtonItem = doneButton
        
        self.navigationItem.title = "Switch button mode"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if appDelegate().modeMap.buttonAppMode() == .SixteenButtons {
            fourAppSwitch.isOn = true
            oneAppSwitch.isOn = false
        } else {
            oneAppSwitch.isOn = true
            fourAppSwitch.isOn = false
        }
        
        performActionsSwitch.isOn = appDelegate().modeMap.buttonActionMode == .performActions
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        appDelegate().mainViewController.didCloseModal()
        appDelegate().redrawMainLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func done(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closeModal()
    }
    
    @IBAction func switchMode(_ sender: UISwitch) {
        if sender == fourAppSwitch {
            if fourAppSwitch.isOn {
                self.switchFourApp()
            } else {
                self.switchOneApp()
            }
        } else {
            if oneAppSwitch.isOn {
                self.switchOneApp()
            } else {
                self.switchFourApp()
            }
        }
    }
    
    func switchFourApp() {
        fourAppSwitch.isOn = true
        oneAppSwitch.isOn = false
        
        appDelegate().modeMap.switchButtonAppMode(.SixteenButtons)
    }
    
    func switchOneApp() {
        oneAppSwitch.isOn = true
        fourAppSwitch.isOn = false
        
        appDelegate().modeMap.switchButtonAppMode(.TwelveButtons)
    }
    
    @IBAction func switchPerformActions(_ sender: UISwitch) {
        appDelegate().modeMap.switchPerformActionMode(sender.isOn ? .performActions : .editActions)
    }
}

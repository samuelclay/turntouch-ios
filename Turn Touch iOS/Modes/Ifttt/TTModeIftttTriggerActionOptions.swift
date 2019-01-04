//
//  TTModeIftttTriggerActionOptions.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 4/27/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

import UIKit

class TTModeIftttTriggerActionOptions: TTOptionsDetailViewController, TTTitleMenuDelegate {

    var menuHeight: Int = 42
    var modeIfttt: TTModeIfttt!

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "TTModeIftttTriggerActionOptions", bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        modeIfttt = (self.action.mode as! TTModeIfttt)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Actions

    @IBAction func openRecipe(sender: UIControl) {
        modeIfttt.registerTriggers {
            self.modeIfttt.openRecipe(direction: self.action.direction)
        }
    }
    
    @IBAction func openSettings(_ sender: UIButton) {
        appDelegate().mainViewController.toggleModeOptionsMenu(sender, delegate: self)
    }
    
    func replaceRecipe() {
        modeIfttt.registerTriggers {
            self.modeIfttt.purgeRecipe(direction: self.action.direction) {
                self.modeIfttt.openRecipe(direction: self.action.direction)
            }
        }
    }
    
    // MARK: Menu Delegate
    
    func menuOptions() -> [[String : String]] {
        return [
            ["title": "Replace this recipe...",
             "image": "remove"],
        ]
    }
    
    func selectMenuOption(_ row: Int) {
        switch row {
        case 0:
            replaceRecipe()
        default:
            break
        }
        appDelegate().mainViewController.closeModeOptionsMenu()
    }
    


}

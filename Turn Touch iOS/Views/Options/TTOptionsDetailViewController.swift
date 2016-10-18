//
//  TTOptionsDetailViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTOptionsDetailViewController: UIViewController {
    
    var mode: TTMode!
    var action: TTAction!
    var menuType: TTMenuType!
    var tabView: TTTabView!
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // Don't touch self.view yet, since lots of instance variables need to be set first
//        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.contentMode = .top
        self.view.clipsToBounds = true
    }

    
    
}

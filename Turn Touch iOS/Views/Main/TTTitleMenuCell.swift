//
//  TTTitleMenuCell.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTTitleMenuCell: UITableViewCell {
    
    var menuTitle = UILabel()
    var menuImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        menuImageView.translatesAutoresizingMaskIntoConstraints = false
        menuTitle.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel?.font = UIFont(name: "Effra", size: 12)
        textLabel?.textColor = UIColor(hex: 0x404A60)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

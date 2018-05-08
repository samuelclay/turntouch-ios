//
//  PresetButtonView.swift
//  STBonjour
//
//  Created by Eric Dolecki on 7/7/16.
//  Copyright © 2016 Eric Dolecki. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PresetButtonDelegate: class {
    optional func presetButtonPressed(sender: PresetButtonView)
}

class PresetButtonView: UIView
{
    var delegate:PresetButtonDelegate?
    var myNumber: Int = -1
    var myName: String = "Unknown"
    var mySource: String = "Unknown"
    var indexLabel: UILabel!
    var nameLabel: UILabel!
    var sourceLabel: UILabel!
    var myButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
    
    init(index:Int, name:String, source:String)
    {
        self.myNumber = index
        self.myName = name
        self.mySource = source
        super.init(frame: CGRect(x: 0, y: 0, width: 130, height: 75))
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor(netHex: 0xF4F4F4).CGColor
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.whiteColor()
        self.generateUI()
    }
    
    func generateUI()
    {
        indexLabel = UILabel(frame: CGRect(x: 0, y: 8, width: self.frame.width, height: 30))
        indexLabel.textColor = UIColor(netHex: 0x474747)
        indexLabel.textAlignment = .Center
        indexLabel.font = UIFont(name: "AvenirNext-Bold", size: 30.0)
        indexLabel.text = String(myNumber)
        
        nameLabel = UILabel(frame: CGRect(x: 5, y: 35, width: self.frame.width - 10, height: 20))
        nameLabel.textColor = UIColor(netHex: 0x474747)
        nameLabel.textAlignment = .Center
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size: 12.0)
        nameLabel.lineBreakMode = .ByTruncatingTail
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7
        nameLabel.text = myName
        
        sourceLabel = UILabel(frame: CGRect(x: 5, y: 50, width: self.frame.width - 10, height: 20))
        sourceLabel.textColor = UIColor(netHex: 0x666666)
        sourceLabel.textAlignment = .Center
        sourceLabel.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
        sourceLabel.lineBreakMode = .ByTruncatingTail
        sourceLabel.adjustsFontSizeToFitWidth = true
        sourceLabel.minimumScaleFactor = 0.7
        sourceLabel.text = mySource
        
        myButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        myButton.addTarget(self, action: #selector(buttonHighlight), forControlEvents: .TouchDown)
        myButton.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
        
        self.addSubview(indexLabel)
        self.addSubview(nameLabel)
        self.addSubview(sourceLabel)
        self.addSubview(myButton)
    }
    
    func buttonHighlight(sender:UIButton){
        self.backgroundColor = UIColor.lightGrayColor()
    }
    
    func buttonPressed(){
        self.backgroundColor = UIColor.whiteColor()
        delegate?.presetButtonPressed!(self)
    }
}
//
//  TTBatchActionHeaderView.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 10/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

class TTBatchActionHeaderView: UIView {
    
    var mode: TTMode
    var batchAction: TTAction?
    
    @IBOutlet var deleteButton: UIButton! = UIButton(type: UIButtonType.system)
    var modeImage = UIImage()
    var modeTitle = ""
    var modeLabel = UILabel()
    var modeImageView = UIImageView()
    var actionLabel = UILabel()
    var diamondView: TTDiamondView!
    
    init(tempMode: TTMode) {
        mode = tempMode
        super.init(frame: CGRect.zero)
        
        self.setupLabels()
    }
    
    init(batchAction: TTAction) {
        self.batchAction = batchAction
        mode = batchAction.mode
        super.init(frame: CGRect.zero)
        
        self.setupLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabels() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = UIViewContentMode.redraw;
        self.backgroundColor = UIColor(hex: 0xFCFCFC)
        self.clipsToBounds = true
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete", for: UIControlState.normal)
        deleteButton.titleLabel!.font = UIFont(name: "Effra", size: 13)
        deleteButton.titleLabel!.textColor = UIColor(hex: 0xA0A0A0)
        deleteButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        deleteButton.addTarget(self, action: #selector(self.pressDelete), for: .touchUpInside)
        self.addSubview(deleteButton)
        self.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .trailingMargin, relatedBy: .equal,
                                              toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: -24))
        self.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        modeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(modeImageView)
        self.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .leadingMargin, relatedBy: .equal,
                                              toItem: self, attribute: .leadingMargin, multiplier: 1.0, constant: 24))
        self.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        modeImageView.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .width, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24))
        modeImageView.addConstraint(NSLayoutConstraint(item: modeImageView, attribute: .height, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24))
        
        modeLabel.font = UIFont(name: "Effra", size: 13)
        modeLabel.textColor = UIColor(hex: 0x404A60)
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(modeLabel)
        self.addConstraint(NSLayoutConstraint(item: modeLabel, attribute: .leading, relatedBy: .equal,
                                              toItem: modeImageView, attribute: .trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: modeLabel, attribute: .width, relatedBy: .equal,
                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 72))
        self.addConstraint(NSLayoutConstraint(item: modeLabel, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        diamondView = TTDiamondView(frame: CGRect.zero, diamondType: .mode)
        diamondView.ignoreSelectedMode = true
        diamondView.ignoreActiveMode = true
        self.addSubview(diamondView)
        let diamondLabelConstraint = NSLayoutConstraint(item: diamondView, attribute: .left, relatedBy: .greaterThanOrEqual,
                                                        toItem: modeLabel, attribute: .right, multiplier: 1.0, constant: 12)
        diamondLabelConstraint.priority = UILayoutPriority.defaultHigh
        self.addConstraint(diamondLabelConstraint)
        self.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .width, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.3*24))
        diamondView.addConstraint(NSLayoutConstraint(item: diamondView, attribute: .height, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 24))
        
        actionLabel.font = UIFont(name: "Effra", size: 13)
        actionLabel.textColor = UIColor(hex: 0x404A60)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(actionLabel)
        self.addConstraint(NSLayoutConstraint(item: actionLabel, attribute: .leading, relatedBy: .equal,
                                              toItem: diamondView, attribute: .trailing, multiplier: 1.0, constant: 12))
        self.addConstraint(NSLayoutConstraint(item: actionLabel, attribute: .centerY, relatedBy: .equal,
                                              toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        

    }
    
    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        modeLabel.text = type(of: mode).title()
        modeImageView.image = UIImage(named:type(of: mode).imageName())
        deleteButton.isHidden = true
        if let action = batchAction {
            actionLabel.text = mode.titleForAction(action.actionName, buttonMoment: .button_MOMENT_PRESSUP)
            deleteButton.isHidden = false
        }
        
        diamondView.overrideActiveDirection = appDelegate().modeMap.inspectingModeDirection
        diamondView.setNeedsDisplay()

        super.draw(rect)
        
        let line = UIBezierPath()
        line.lineWidth = 0.5
        UIColor(hex: 0xC2CBCE).set()
        
        // Top border
        line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
        line.stroke()
        
        // Bottom border
        line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        line.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        line.stroke()
    }
    
    
    
    // MARK: Actions
    
    @objc func pressDelete(_ sender: UIButton!) {
        if let action = batchAction {
            appDelegate().modeMap.removeBatchAction(for: action.batchActionKey!)
            appDelegate().mainViewController.batchActionsStackView.hideBatchAction(batchActionKey: action.batchActionKey!)
            
            appDelegate().modeMap.recordUsage(additionalParams: ["moment": "change:remove-batch-action:\(action.batchActionKey!)"])
        }
    }
}

//
//  TTModeMenuContainer.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/1/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTMenuType {
    case MENU_MODE
    case MENU_ACTION
    case MENU_ADD_MODE
    case MENU_ADD_ACTION
}

class TTModeMenuContainer: UIView {
    @IBInspectable var MENU_HEIGHT: CGFloat = 100
    @IBInspectable var MENU_WIDTH: CGFloat = 176
    
    var menuType: TTMenuType = .MENU_MODE
    var bordersView = TTModeMenuBordersView()
    var collectionView: TTModeMenuCollectionView!
    let flowLayout = UICollectionViewFlowLayout()
    
    init(menuType: TTMenuType) {
        super.init(frame: CGRectZero)
        translatesAutoresizingMaskIntoConstraints = false
        self.menuType = menuType
        
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true

        flowLayout.itemSize = CGSizeMake(MENU_WIDTH, MENU_HEIGHT/2)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView = TTModeMenuCollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alpha = 0
        self.addSubview(collectionView)
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Height,
            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: MENU_HEIGHT))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Width,
            relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Top,
            relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Left,
            relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))

        self.addSubview(bordersView)
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .Height,
            relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .Width,
            relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .Top,
            relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .Left,
            relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        
//        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "openedModeChangeMenu" {
            self.toggleModeMenu()
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
    }

    // MARK: Drawing
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    func toggleModeMenu() {
        if menuType == .MENU_MODE {
            UIView.animateWithDuration(0.5, animations: {
                self.collectionView.flashScrollIndicators()
                let openedModeChangeMenu: Bool = appDelegate().modeMap.openedModeChangeMenu
                if openedModeChangeMenu {
                    self.bordersView.setNeedsDisplay()
                }
                
                self.collectionView.alpha = openedModeChangeMenu ? 1.0 : 0
                self.setNeedsLayout()
                }, completion: { (done) in
                    let openedModeChangeMenu: Bool = appDelegate().modeMap.openedModeChangeMenu
                    if !openedModeChangeMenu {
                        self.bordersView.setNeedsDisplay()
                    }
            })
        }
    }
    
}

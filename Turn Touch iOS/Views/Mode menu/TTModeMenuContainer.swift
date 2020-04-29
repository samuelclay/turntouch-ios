//
//  TTModeMenuContainer.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/1/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTMenuType {
    case menu_MODE
    case menu_ACTION
    case menu_ADD_MODE
    case menu_ADD_ACTION
}

#if !WIDGET
class TTModeMenuContainer: UIView {
    @IBInspectable var MENU_HEIGHT: CGFloat = 100
    @IBInspectable var MENU_WIDTH: CGFloat = 150
    
    var menuType: TTMenuType = .menu_MODE
    var bordersView = TTModeMenuBordersView()
    var collectionView: TTModeMenuCollectionView!
    let flowLayout = UICollectionViewFlowLayout()
    
    init(menuType: TTMenuType) {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.menuType = menuType
        
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        
        if menuType == .menu_MODE || menuType == .menu_ADD_MODE {
            flowLayout.itemSize = CGSize(width: MENU_WIDTH, height: MENU_HEIGHT/2)
        } else if menuType == .menu_ACTION || menuType == .menu_ADD_ACTION {
            flowLayout.itemSize = CGSize(width: MENU_WIDTH*1.2, height: MENU_HEIGHT/2)
        }
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        collectionView = TTModeMenuCollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alpha = 0
        collectionView.menuType = menuType
        self.addSubview(collectionView)
        
        guard let collectionView = collectionView else {
            return
        }
        
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .height,
            relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: MENU_HEIGHT))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .width,
            relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top,
            relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .left,
            relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))

        self.addSubview(bordersView)
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .height,
            relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .width,
            relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .top,
            relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bordersView, attribute: .left,
            relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
        
        self.registerAsObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: KVO
    
    func registerAsObserver() {
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedModeChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedActionChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "openedAddActionChangeMenu", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "availableActions", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "inspectingModeDirection", options: [], context: nil)
        appDelegate().modeMap.addObserver(self, forKeyPath: "tempModeName", options: [], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "openedModeChangeMenu" {
            self.toggleModeMenu()
        } else if keyPath == "openedActionChangeMenu" {
            self.toggleModeMenu()
        } else if keyPath == "openedAddActionChangeMenu" {
            self.toggleModeMenu()
        } else if keyPath == "tempModeName" {
            self.toggleModeMenu()
        } else if keyPath == "availableActions" {
            collectionView.reloadData()
        } else if keyPath == "inspectingModeDirection" {
            if menuType == .menu_MODE && appDelegate().modeMap.inspectingModeDirection != .no_DIRECTION {
                if appDelegate().modeMap.openedModeChangeMenu {
                    appDelegate().modeMap.openedModeChangeMenu = false
                }
            }
        }
    }
    
    deinit {
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedModeChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedActionChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "openedAddActionChangeMenu")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "availableActions")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "inspectingModeDirection")
        appDelegate().modeMap.removeObserver(self, forKeyPath: "tempModeName")
    }

    // MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func toggleModeMenu() {
        if menuType == .menu_MODE {
            UIView.animate(withDuration: 0.5, animations: {
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
        } else if menuType == .menu_ACTION {
            UIView.animate(withDuration: 0.5, animations:
                {
                    self.collectionView.flashScrollIndicators()
                    let openedActionChangeMenu: Bool = appDelegate().modeMap.openedActionChangeMenu
                    if openedActionChangeMenu {
                        self.bordersView.setNeedsDisplay()
                    }
                    
                    self.collectionView.alpha = openedActionChangeMenu ? 1.0 : 0
                    self.setNeedsLayout()
                }, completion: { (done) in
                    let openedActionChangeMenu: Bool = appDelegate().modeMap.openedActionChangeMenu
                    if !openedActionChangeMenu {
                        self.bordersView.setNeedsDisplay()
                    }
                })
        } else if menuType == .menu_ADD_MODE || menuType == .menu_ADD_ACTION {
            if menuType == .menu_ADD_MODE && appDelegate().modeMap.tempModeName != nil {
                menuType = .menu_ADD_ACTION
                collectionView.menuType = menuType
                self.collectionView.reloadData()
            } else if menuType == .menu_ADD_ACTION && appDelegate().modeMap.tempModeName == nil {
                menuType = .menu_ADD_MODE
                collectionView.menuType = menuType
                self.collectionView.reloadData()
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.collectionView.flashScrollIndicators()
                let openedModeChangeMenu: Bool = appDelegate().modeMap.openedAddActionChangeMenu
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
#endif

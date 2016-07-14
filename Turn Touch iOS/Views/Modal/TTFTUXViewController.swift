//
//  TTFTUXViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit


enum TTFTUXPage: Int {
    case Intro
    case Actions
    case Modes
    case BatchActions
    case HUD
}

class TTFTUXViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    var nextButton: TTModalButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton = TTModalButton(ftuxPage: .Intro)
        self.view.addSubview(nextButton.view)
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal,
            toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Left, relatedBy: .Equal,
            toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Right, relatedBy: .Equal,
            toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal,
            toItem: nextButton, attribute: .Top, multiplier: 1.0, constant: 0))
        
        pageControl.numberOfPages = 5
        self.view.addSubview(pageControl)
        self.view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal,
            toItem: nextButton, attribute: .Top, multiplier: 1.0, constant: 16))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Left, relatedBy: .Equal,
            toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Right, relatedBy: .Equal,
            toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0))
        
        for index in 0..<5 {
            let frame = CGRect(x: CGFloat(index) * CGRectGetWidth(scrollView.frame), y: 0,
                               width: CGRectGetWidth(scrollView.frame), height: CGRectGetHeight(scrollView.frame))
            let ftuxView = TTFTUXView(frame: frame, ftuxPage: TTFTUXPage(rawValue: index)!)
            scrollView.addSubview(ftuxView)
        }
    }
    
    func setPage(ftuxPage: TTFTUXPage) {
        pageControl.currentPage = ftuxPage.hashValue
        scrollView.setContentOffset(CGPointMake(CGFloat(pageControl.currentPage) * CGRectGetWidth(scrollView.frame), 0),
                                    animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame))
    }
}

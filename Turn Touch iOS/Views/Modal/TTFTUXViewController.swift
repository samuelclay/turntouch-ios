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
    let pages = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = UIColor.whiteColor()

        let closeButton = UIBarButtonItem(barButtonSystemItem: .Cancel,
                                          target: self, action: #selector(self.close))
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.title = "How it works"

        nextButton = TTModalButton(ftuxPage: .Intro)
        self.view.addSubview(nextButton.view)
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Left, relatedBy: .Equal,
            toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Bottom, relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Width, relatedBy: .Equal,
            toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal,
            toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Left, relatedBy: .Equal,
            toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Width, relatedBy: .Equal,
            toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal,
            toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -100))
        
        pageControl.numberOfPages = pages
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = UIColor(hex: 0xE0E0E0)
        pageControl.currentPageIndicatorTintColor = UIColor(hex: 0xA06060)
        self.view.addSubview(pageControl)
        self.view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal,
            toItem: nextButton.view, attribute: .Top, multiplier: 1.0, constant: -24))
        self.view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal,
            toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        var previousFtuxView: TTFTUXView?
        for index in 0..<pages {
            //            let frame = CGRect(x: CGFloat(index) * CGRectGetWidth(self.view.frame), y: 0,
            //                               width: CGRectGetWidth(self.view.frame), height: CGRectGetHeight(self.view.frame))
            let ftuxView = TTFTUXView(ftuxPage: TTFTUXPage(rawValue: index)!)
            scrollView.addSubview(ftuxView)
            
            scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .Width, relatedBy: .Equal,
                toItem: scrollView, attribute: .Width, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .Height, relatedBy: .Equal,
                toItem: scrollView, attribute: .Height, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .Left, relatedBy: .Equal,
                toItem: previousFtuxView ?? scrollView, attribute: previousFtuxView != nil ? .Right : .Left, multiplier: 1.0, constant: 0))
            if index == pages - 1 {
                scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .Right, relatedBy: .Equal,
                    toItem: scrollView, attribute: .Right, multiplier: 1.0, constant: 0))
            }
            previousFtuxView = ftuxView
        }
        
    }
    
    func close(sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closeFtuxModal()
    }
    
    override func viewWillAppear(animated: Bool) {
        scrollView.contentSize = CGSize(width: CGFloat(pages)*CGRectGetWidth(scrollView.frame), height: CGRectGetHeight(scrollView.frame))

        self.setPage(.Intro)
    }
    
    func setPage(ftuxPage: TTFTUXPage) {
//        pageControl.currentPage = ftuxPage.hashValue // handled in scrollViewDidScroll
        scrollView.setContentOffset(CGPointMake(CGFloat(ftuxPage.rawValue) * CGRectGetWidth(scrollView.frame), 0),
                                    animated: true)
        nextButton.ftuxPage = ftuxPage
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)))
        nextButton.ftuxPage = TTFTUXPage(rawValue: pageControl.currentPage)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)))
        nextButton.ftuxPage = TTFTUXPage(rawValue: pageControl.currentPage)
    }
}

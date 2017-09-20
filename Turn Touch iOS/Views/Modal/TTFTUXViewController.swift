//
//  TTFTUXViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 7/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit


enum TTFTUXPage: Int {
    case intro
    case actions
    case modes
    case batchActions
    case hud
}

class TTFTUXViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    var nextButton: TTModalButton!
    let pages = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = UIColor.white

        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                          target: self, action: #selector(self.close))
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.title = "How it works"

        nextButton = TTModalButton(ftuxPage: .intro)
        self.view.addSubview(nextButton.view)
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .left, relatedBy: .equal,
            toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .bottom, relatedBy: .equal,
            toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .width, relatedBy: .equal,
            toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: nextButton.view, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal,
            toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal,
            toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal,
            toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0))
        
        pageControl.numberOfPages = pages
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = UIColor(hex: 0xE0E0E0)
        pageControl.currentPageIndicatorTintColor = UIColor(hex: 0xA06060)
        self.view.addSubview(pageControl)
        self.view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal,
            toItem: nextButton.view, attribute: .top, multiplier: 1.0, constant: -24))
        self.view.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal,
            toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal,
                                                   toItem: pageControl, attribute: .top, multiplier: 1.0, constant: -24))
        
        var previousFtuxView: TTFTUXView?
        for index in 0..<pages {
            //            let frame = CGRect(x: CGFloat(index) * CGRectGetWidth(self.view.frame), y: 0,
            //                               width: CGRectGetWidth(self.view.frame), height: CGRectGetHeight(self.view.frame))
            let ftuxView = TTFTUXView(ftuxPage: TTFTUXPage(rawValue: index)!)
            scrollView.addSubview(ftuxView)
            
            scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .top, relatedBy: .equal,
                toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .width, relatedBy: .equal,
                toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .height, relatedBy: .equal,
                toItem: scrollView, attribute: .height, multiplier: 1.0, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .left, relatedBy: .equal,
                toItem: previousFtuxView ?? scrollView, attribute: previousFtuxView != nil ? .right : .left, multiplier: 1.0, constant: 0))
            if index == pages - 1 {
                scrollView.addConstraint(NSLayoutConstraint(item: ftuxView, attribute: .right, relatedBy: .equal,
                    toItem: scrollView, attribute: .right, multiplier: 1.0, constant: 0))
            }
            previousFtuxView = ftuxView
        }
        
    }
    
    @objc func close(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closeFtuxModal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: CGFloat(pages)*scrollView.frame.width, height: scrollView.frame.height)

        self.setPage(.intro)
    }
    
    func setPage(_ ftuxPage: TTFTUXPage) {
//        pageControl.currentPage = ftuxPage.hashValue // handled in scrollViewDidScroll
        scrollView.setContentOffset(CGPoint(x: CGFloat(ftuxPage.rawValue) * scrollView.frame.width, y: 0),
                                    animated: true)
        nextButton.ftuxPage = ftuxPage
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        nextButton.ftuxPage = TTFTUXPage(rawValue: pageControl.currentPage)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        nextButton.ftuxPage = TTFTUXPage(rawValue: pageControl.currentPage)
    }
}

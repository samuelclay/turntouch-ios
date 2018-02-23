//
//  TTAboutViewController.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

import Foundation
import SafariServices

class TTAboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    let CellReuseIdentifier = "TTTitleMenuCell"
    @IBOutlet var twitterTable: UITableView!
    @IBOutlet var twitterTableHeightConstraint: NSLayoutConstraint!

    required init() {
        super.init(nibName: "TTAboutViewController", bundle: Bundle.main)

        let closeButton = UIBarButtonItem(barButtonSystemItem: .done,
                                          target: self, action: #selector(self.close))
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.title = "About Turn Touch"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        twitterTableHeightConstraint.constant = CGFloat(max(44, self.menuOptions().count * Int(self.tableView(twitterTable, heightForRowAt: IndexPath(item: 0, section: 0)))))
    }
    
    @objc func close(_ sender: UIBarButtonItem!) {
        appDelegate().mainViewController.closeModal()
    }
    
    // MARK: Twitter Table
    
    func menuOptions() -> [[String : String]] {
        return [
            ["title": "Follow @turntouch on Twitter",
             "subtitle": "Announcements and updates",
             "image": "twitter-turntouch",
             "url": "https://twitter.com/turntouch"],
            ["title": "Follow @samuelclay on Twitter",
             "subtitle": "Designer and builder",
             "image": "twitter-samuelclay",
             "url": "https://twitter.com/samuelclay"],
            ["title": "Buy a Turn Touch",
             "subtitle": "Only at turntouch.com",
             "image": "twitter-buy",
             "url": "https://shop.turntouch.com"],
            ["title": "Review on the App Store",
             "subtitle": "Rate this app",
             "image": "twitter-review",
             "url": "itms-apps://itunes.apple.com/us/app/itunes-u/id1152075244?action=write-review"],
        ]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuOptions().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier) as? TTTitleMenuCell
        if cell == nil {
            cell = TTTitleMenuCell(style: .subtitle, reuseIdentifier: CellReuseIdentifier)
        }
        
        cell!.textLabel?.text = self.menuOptions()[(indexPath as NSIndexPath).row]["title"]
        cell!.imageView?.image = UIImage(named: self.menuOptions()[(indexPath as NSIndexPath).row]["image"] ?? "alarm_snooze")
        cell!.detailTextLabel?.text = self.menuOptions()[(indexPath as NSIndexPath).row]["subtitle"]?.uppercased()
        
        let itemSize:CGSize = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect : CGRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
        cell!.imageView!.image?.draw(in: imageRect)
        cell!.imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell!.contentView.setNeedsLayout()
        cell!.contentView.layoutIfNeeded()
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = self.menuOptions()[indexPath.row]["url"] else {
            return
        }
        
        if url.starts(with: "itms"), let reviewURL = URL(string: url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(reviewURL)
            }
        } else {
            if let twitterUrl = URL(string: url) {
                let supportViewController = SFSafariViewController(url: twitterUrl)
                supportViewController.delegate = self
                self.navigationController?.present(supportViewController, animated: true, completion: nil)
            }
        }
    }

}

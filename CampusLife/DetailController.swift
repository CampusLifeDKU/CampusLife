//
//  DetailController.swift
//  CampusLife
//
//  Created by Daesub Kim on 2016. 12. 6..
//  Copyright © 2016년 DaesubKim. All rights reserved.
//

import UIKit
class DetailController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var regionBottom: UIBarButtonItem!
    @IBOutlet weak var distanceTop: UINavigationItem!
    
    var paper: Paper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("HERE !!!!! ")
        
        contentTextView.scrollEnabled = false
        contentTextView.delegate = self
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        contentTextView.scrollEnabled = true
        
        if let paper = paper {
            idLabel.text = self.paper!.id
            titleLabel.text = self.paper!.title
            contentTextView.text = self.paper!.content
            idLabel.text = self.paper!.id
            idLabel.text = self.paper!.id
            distanceTop.title = ""
            regionBottom.title = self.paper!.region
        }
    }
    
    @IBAction func backBtn(sender: UIBarButtonItem) {
        //self.navigationController?.popViewControllerAnimated(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
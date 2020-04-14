//
//  SubscrptionViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 14/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit


class SubscriptionViewController: UIViewController {
    
    
    @IBOutlet weak var headerForSub: UILabel!
    @IBOutlet weak var imageForSub: UIImageView!
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        headerForSub.text = subsNameArr[rowIndex]
    }
        override func viewWillDisappear(_ animated: Bool) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
}

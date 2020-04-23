//
//  ViewSubscriptionViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 23/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

class ViewSubscriptionViewController: UIViewController {
    @IBOutlet weak var infotab: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infotab.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(netHex: 0x353535)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

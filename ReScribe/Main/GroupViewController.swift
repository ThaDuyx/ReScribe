//
//  GroupViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 09/03/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {

    @IBOutlet weak var infotabView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
    }
}

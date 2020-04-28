//
//  TabBarController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 20/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation
import UIKit

let cellHeight: CGFloat = 5


class TabBarController: UITabBarController {

   override func viewDidLoad() {
       super.viewDidLoad()
       self.selectedIndex = 1
   }

}

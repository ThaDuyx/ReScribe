//
//  IndvidualUpcomingViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 22/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation
import UIKit

class IndvidualUpcomingViewController: UIViewController {
    @IBOutlet weak var addButtonUI: UIButton!
    @IBOutlet weak var infotabView: UIView!
    @IBOutlet weak var indvidualTableView: UITableView!
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.addButtonUI.round(corners: [.bottomLeft, .bottomRight, .topRight, .topLeft], cornerRadius: 20)
    }
}

extension IndvidualUpcomingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = indvidualTableView.dequeueReusableCell(withIdentifier: "upcomingPayments", for: indexPath) as! IndvidualTableViewCell
        cell.costLabel.text = nameArr[indexPath.row]
        return cell
    }
}

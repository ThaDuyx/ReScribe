//
//  GroupViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 09/03/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {

    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var groupAddButton: UIButton!
    @IBOutlet weak var infotabView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.groupAddButton.round(corners: .allCorners, cornerRadius: 20)
    }
}

extension GroupViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return subsNameArr.count
     }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupTableView.dequeueReusableCell(withIdentifier: "groups", for: indexPath) as! GroupTableViewCell
        cell.groupNameLabel.text = subsNameArr[indexPath.section]

        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}


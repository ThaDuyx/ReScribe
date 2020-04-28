//
//  AddGroupViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 28/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupMembersTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var infoView: UIView!
    override func viewDidLoad() {
       super.viewDidLoad()
        self.infoView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.addButton.round(corners: .allCorners, cornerRadius: 10)
   }
}

extension AddGroupViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return subsNameArr.count
     }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupMembersTableView.dequeueReusableCell(withIdentifier: "groupMember", for: indexPath) as! GroupMemberTableViewCell
        cell.groupMemberLabel.text = subsNameArr[indexPath.section]

        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

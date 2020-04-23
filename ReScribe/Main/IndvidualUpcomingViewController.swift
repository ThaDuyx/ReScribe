//
//  IndvidualUpcomingViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 22/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

let daysArr = ["1","2"]
let nnameArr = ["155", "278"]
let cellSpacingHeight: CGFloat = 5

class IndvidualUpcomingViewController: UIViewController {
    @IBOutlet weak var addButtonUI: UIButton!
    @IBOutlet weak var infotabView: UIView!
    @IBOutlet weak var indvidualTableView: UITableView!
    @IBOutlet weak var viewTableView: UIView!
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.addButtonUI.round(corners: [.bottomLeft, .bottomRight, .topRight, .topLeft], cornerRadius: 20)
        self.viewTableView.round(corners: .allCorners, cornerRadius: 10)
    }
}

extension IndvidualUpcomingViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowIndex = indexPath.row
        
        performSegue(withIdentifier: "viewSubs", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return nnameArr.count
     }

     // Set the spacing between sections
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return cellSpacingHeight
     }

     // Make the background color show through
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let headerView = UIView()
         headerView.backgroundColor = UIColor.clear
         return headerView
     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = indvidualTableView.dequeueReusableCell(withIdentifier: "upcomingPayments", for: indexPath) as! IndvidualTableViewCell
        cell.costLabel.text = nnameArr[indexPath.section] + ",-  dkk"
        cell.timeLabel.text = daysArr[indexPath.section] + "    days"
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

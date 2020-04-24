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
    @IBOutlet weak var tableView: UITableView!
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
extension ViewSubscriptionViewController: UITableViewDataSource, UITableViewDelegate {
    
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "plansCell", for: indexPath) as! ViewSubscriptionTableViewCell
        cell.amountLabel.text = nnameArr[indexPath.section] + ",-  dkk"
        cell.packagePlanLabel.text = daysArr[indexPath.section] + "    days"
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

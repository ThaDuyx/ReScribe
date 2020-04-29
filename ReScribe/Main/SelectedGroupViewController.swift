//
//  SelectedGroupViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 28/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

class SelectedGroupViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.init(netHex: 0x353535)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension SelectedGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowIndex = indexPath.section
        performSegue(withIdentifier: "viewSubs", sender: self)
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "upcomingPayments", for: indexPath) as! TableViewCell
        cell.selectedGroupTimeLabel.text = subsNameArr[indexPath.section]

        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
    
    
}

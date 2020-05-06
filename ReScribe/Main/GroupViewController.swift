//
//  GroupViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 09/03/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit
import Firebase
import EFCountingLabel

class GroupViewController: UIViewController {

    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var groupAddButton: UIButton!
    @IBOutlet weak var infotabView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var groupExpenseLabel: EFCountingLabel!
    var groupList = [Group]()
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    var groupIDs = [String]()
    var totalGroupAmount: Int = 0
    var root = "groups"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.groupAddButton.round(corners: .allCorners, cornerRadius: 20)
        self.backgroundView.round(corners: .allCorners, cornerRadius: 10)
        
        db.collection("users").document(userID).collection("Groups").addSnapshotListener { (gSnapshot, error) in
            let groupChange = gSnapshot
            groupChange?.documentChanges.forEach({ (DocumentChange) in
                if DocumentChange.type == .added{
                    let newGroup = DocumentChange.document.data()
                    let objectGID = newGroup["gid"] as! String
                    let objectGName = newGroup["name"] as! String
                    self.groupList.append(Group(id: objectGID, name: objectGName)!)
                    self.db.collection("groups").document(objectGID).collection("Subs").addSnapshotListener { (groupSubsSnap, error) in
                        
                        if let error = error{
                            print("Error getting change: \(error)")
                        } else {
                            groupSubsSnap?.documentChanges.forEach({ (groupSubChange) in
                                
                                if groupSubChange.type == .added{
                                    let price = groupSubChange.document.data()
                                    let priceQuery = price["price"] as! Int
                                    self.totalGroupAmount += priceQuery
                                }
                                    
                                else if groupSubChange.type == .modified{
                                    let priceChange = groupSubChange.document.data()
                                    let priceQuery = priceChange["price"] as! Int
                                    let modifiedStatus = priceChange["status"] as! Bool
                                    if modifiedStatus == true{
                                        self.totalGroupAmount += priceQuery
                                    } else {
                                        self.totalGroupAmount -= priceQuery
                                    }
                                }
                                    
                                else if groupSubChange.type == .removed{
                                    let priceRemove = groupSubChange.document.data()
                                    let priceRemoveQuery = priceRemove["price"] as! Int
                                    self.totalGroupAmount -= priceRemoveQuery
                                }
                                
                                else {
                                    print("Something went wrong")
                                }
                            })
                            DispatchQueue.main.async {
                                self.groupExpenseLabel.countFrom(0, to: CGFloat(self.totalGroupAmount))
                            }
                        }
                    }
                }
                if DocumentChange.type == .removed{
                    let removedData = DocumentChange.document.data()
                    let removedGroupId = removedData["gid"] as! String
                    for group in self.groupList{
                        if removedGroupId == group.gid{
                            self.groupList.removeAll { $0.gid == removedGroupId }
                            self.groupTableView.reloadData()

                        }
                    }
                }
            })
            DispatchQueue.main.async {
                self.groupTableView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.groupTableView.indexPathsForSelectedRows {
            for at in index {
                self.groupTableView.deselectRow(at: at, animated: true)
            }
        }
    }
}

extension GroupViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
         return groupList.count
     }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add"{
            let vc = segue.destination as! SelectedGroupViewController
            vc.selectedGroup = groupList[rowIndex]
            vc.root = root
        }
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
        let cell = groupTableView.dequeueReusableCell(withIdentifier: "groups", for: indexPath) as! TableViewCell
        cell.groupNameLabel.text = groupList[indexPath.section].name

        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowIndex = indexPath.section
        
        performSegue(withIdentifier: "add", sender: self)
    }
}

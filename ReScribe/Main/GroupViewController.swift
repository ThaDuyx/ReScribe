//
//  GroupViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 09/03/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit
import Firebase

class GroupViewController: UIViewController {

    @IBOutlet weak var groupTableView: UITableView!
    @IBOutlet weak var groupAddButton: UIButton!
    @IBOutlet weak var infotabView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    var groupList = [Group]()
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    var groupIDs = [String]()
    var totalGroupAmount: Int = 0
    
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
                    print(newGroup)
                    let objectGID = newGroup["gid"] as! String
                    let objectGName = newGroup["name"] as! String
                    self.groupList.append(Group(id: objectGID, name: objectGName)!)
                }
            })
            DispatchQueue.main.async {
                self.groupTableView.reloadData()
            }
        }
        db.collection("groups").addSnapshotListener { (allGroups, error) in
            let groupsThing = allGroups
            groupsThing?.documentChanges.forEach({ (DocumentChange) in
                if DocumentChange.type == .added{
                    for group in self.groupList{
                        self.db.collection("groups").document(group.gid).collection("Subs").addSnapshotListener { (exactGroupSnapshot, error) in
                            exactGroupSnapshot?.documentChanges.forEach({ (groupSub) in
                                let price = groupSub.document.data()
                                let priceQuery = price["price"] as! Int
                                self.totalGroupAmount += priceQuery
                            })
                            DispatchQueue.main.async {
                                print(self.totalGroupAmount)
                                
                            }
                        }
                    }
                }
            })
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
        rowIndex = indexPath.row
        
        performSegue(withIdentifier: "add", sender: self)
    }
}


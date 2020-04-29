//
//  AddGroupViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 28/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit
import Firebase

class AddGroupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupMembersTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var groupMembersTableView: UITableView!
    @IBOutlet weak var infoView: UIView!
    var userlist = [User]()
    var addedusers = [String]()
    let userID = Auth.auth().currentUser!.uid
    override func viewDidLoad() {
       super.viewDidLoad()
        self.infoView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.addButton.round(corners: .allCorners, cornerRadius: 10)
        //loadUsers()

        groupNameTextField.delegate = self
        groupMembersTextField.delegate = self
   }
    
    @IBAction func addGroupTapped(_ sender: Any) {
        let db = Firestore.firestore()
        let newGroup = db.collection("groups").document()
        newGroup.setData(["name":groupNameTextField.text!, "gid":newGroup.documentID]) { (error) in
            if error != nil{
                print(error!)
            } else {
                let allusers = db.collection("groups").document(newGroup.documentID).collection("users")
                for eachUser in self.addedusers{
                    allusers.document(eachUser).setData(["name" : eachUser])
                }
                db.collection("users").document(self.userID).collection("Groups").document(newGroup.documentID).setData(["name" : self.groupNameTextField.text!]) { (error) in
                    if error != nil{
                        print(error!)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func loadUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (usersnapshot, error) in
            
            for user in usersnapshot!.documents{
                let userref = user.data()
                self.userlist.append(User(uid: userref["uid"] as! String, name: userref["name"] as! String)!)
                
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == groupMembersTextField{
            if groupMembersTextField.text != ""{
                addedusers.append(textField.text!)
                groupMembersTableView.reloadData()
                textField.text! = ""
            }
        }
        textField.resignFirstResponder()
        return true
    }
}


extension AddGroupViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return addedusers.count
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
        let cell = groupMembersTableView.dequeueReusableCell(withIdentifier: "groupMember", for: indexPath) as! TableViewCell
        cell.addMemberLabel.text = addedusers[indexPath.section]

        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

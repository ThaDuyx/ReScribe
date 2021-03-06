//
//  SubscrptionViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 14/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class SubscriptionViewController: UIViewController {
    
    let datePicker = UIDatePicker()
    let storage = Storage.storage()
    @IBOutlet weak var planView: UITableView!
    @IBOutlet weak var infotabView: UIView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var headerForSub: UILabel!
    @IBOutlet weak var imageForSub: UIImageView!
    @IBOutlet weak var datePick: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var viewOfContent: UIView!
    
    let userID = Auth.auth().currentUser!.uid
    let db = Firestore.firestore()
    var genreString = ""
    var headerName = ""
    var root = ""
    var planName = ""
    var price = 0
    var subPlans = [Plan]()
    var toBeStoredNextPaymentDate = ""
    var groupID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planView.delegate = self
        planView.dataSource = self
        headerForSub.text = headerName
        
        //Image query in Firebase Storage
        let storageRef = storage.reference()
        let starsRef = storageRef.child("Images/" + headerName + ".jpg")
        let imageView: UIImageView = self.imageForSub
        let placeholderImage = UIImage(named: "Netflix.jpg")
        imageView.sd_setImage(with: starsRef, placeholderImage: placeholderImage)
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.addBtn.round(corners: [.allCorners], cornerRadius: 10)
        self.viewOfContent.round(corners: .allCorners, cornerRadius: 10)
        //Genre query
        db.collection("Subscriptions").document(headerName).getDocument { (document, err) in
            if let data = document?.data(){
                self.genreString = data["Genre"] as! String
                self.genreLabel.text = self.genreString
            } else {
                print("No document")
            }
        }
        
        db.collection("Subscriptions").document(headerName).collection("Plan").getDocuments { (snapShot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapShot!.documents {
                    let planData = document.data()
                    self.subPlans.append(Plan(name: planData["Name"] as! String, price: planData["Price"] as! Int)!)
                    DispatchQueue.main.async {
                        self.planView.reloadData()
                    }
                }
            }
        }
        
        //Creation of date tool
        instanceOfDate()
    }
        override func viewWillDisappear(_ animated: Bool) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    
    
    //Inspiration taken from this video with minor modifications:
    //https://www.youtube.com/watch?v=8NngJrVFfUw&t=188s
    func instanceOfDate(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneTapped))
        toolbar.setItems([doneBtn], animated: true)
        datePick.inputAccessoryView = toolbar
        datePick.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    
    //Inspiration taken from this video with minor modifications:
    //https://www.youtube.com/watch?v=8NngJrVFfUw&t=188s
    @objc func doneTapped() {
        //Creating date and showing it on the label
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let pickedDate = dateFormatter.string(from: datePicker.date)
        datePick.text = pickedDate
    
        //Finding the next payment date 1 month ahead of time
        let dateObject = datePicker.date
        let calender = Calendar.current
        let nextPaymentDate = calender.date(byAdding: .day, value: 31, to: dateObject)
        toBeStoredNextPaymentDate = dateFormatter.string(from: nextPaymentDate!)
        
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        planView.reloadData()
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        
        if datePick.text!.isEmpty || planName == ""{
            
            let refreshAlert = UIAlertController(title: "Error", message: "Pick a date and payment plan to continue", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
             present(refreshAlert, animated: true, completion: nil)
        } else {
            if root == "personal"{
                let newSubDocument = db.collection("users").document(userID).collection("Subs").document()
                newSubDocument.setData(["subid":newSubDocument.documentID, "company":headerName, "genre":genreString, "date":datePick.text!, "status":true , "plan":planName, "price":price, "nextdate":toBeStoredNextPaymentDate]) { (error) in
                    if error != nil {
                        print("Oh no")
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            } else if root == "groups"{
                let groupCount = db.collection("users").document(userID).collection("Groups").document(groupID)
                groupCount.getDocument { (groupMember, error) in
                    if let error = error {
                        print(error)
                    } else {
                        let groupRef = groupMember?.data()
                        let groupQuantity = groupRef!["membercount"] as! Int
                    
                        
                        let newGroupSubDocument = self.db.collection("groups").document(self.groupID).collection("Subs").document()
                        newGroupSubDocument.setData(["subid":newGroupSubDocument.documentID, "company":self.headerName, "genre":self.genreString, "date":self.datePick.text!, "status":true, "plan":self.planName, "price":self.price/groupQuantity, "nextdate":self.toBeStoredNextPaymentDate]) { (error) in
                            if error != nil {
                                print("Oh no")
                            } else {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
            } else {
                print("Something went wrong, try reconnecting to internet")
            }
        }
    }
}

extension SubscriptionViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return subPlans.count
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
        let cell = planView.dequeueReusableCell(withIdentifier: "plansCell", for: indexPath) as! TableViewCell
        cell.subscriptionPackageLabel.text = subPlans[indexPath.section].name
        cell.subscriptionAmountLabel.text = String(subPlans[indexPath.section].price)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(netHex: 0x68b2b3)
        cell.selectedBackgroundView = bgColorView
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        planName = subPlans[indexPath.section].name
        price = subPlans[indexPath.section].price
    }
}


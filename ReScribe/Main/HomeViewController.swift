//
//  HomeViewController.swift
//  ReScribe
//
//  Created by Simon Andersen on 09/03/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
//Taken from this github repo: https://github.com/EFPrefix/EFCountingLabel
import EFCountingLabel

class HomeViewController: UIViewController {
   
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var inviView: UIView!
    @IBOutlet weak var infotabView: UITableView!
    @IBOutlet weak var totalAmountLabel: EFCountingLabel!
    @IBOutlet weak var inviTableView: UITableView!
    @IBOutlet weak var groupTableView: UITableView!
    
    //For database queries
    let storage = Storage.storage()
    let userID = Auth.auth().currentUser!.uid
    let db = Firestore.firestore()
    var individualSubs = [Subscription]()
    var groupSubs = [Subscription]()
    var totalExpense: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inviView.round(corners: [.allCorners], cornerRadius: 10)
        self.groupView.round(corners: [.allCorners], cornerRadius: 10)
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.totalAmountLabel.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 3)
        
        let storageRef = storage.reference()
        //Personal sub query - Subs are stored in the user data and adds a snapshot listener that listens for every change made within the users subs
        db.collection("users").document(userID).collection("Subs").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error getting change: \(error)")
            } else {
                let newDocument = snapshot
                newDocument?.documentChanges.forEach({ change in
                    //When personal subs are added
                    if change.type == .added {
                        let newData = change.document.data()
                        let companyName = newData["company"] as! String
                        let subPlan = newData["plan"] as! String
                        let subPrice = newData["price"] as! Int
                        self.totalExpense += subPrice
                        let subGenre = newData["genre"] as! String
                        let subStatus = newData["status"] as! Bool
                        let subID = newData["subid"] as! String
                        let subDate = newData["date"] as! String
                        let subNextDate = newData["nextdate"] as! String
                        let starsRef = storageRef.child("Images/" + companyName  + ".jpg")
                        let remaining = self.calculateDatesRemaining(dateString: subNextDate)
                        starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                            if let error = error {
                              print("Error \(error)")
                            } else {
                                let logoImage = UIImage(data: data!)!
                                if subStatus == true {
                                    self.individualSubs.append(Subscription(id:subID, name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate, nextdate: subNextDate, remainingDays: remaining)!)
                                }
                                DispatchQueue.main.async {
                                    self.sortSubscriptions()
                                    self.inviTableView.reloadData()
                                    let totalAmount = self.calculateTotalAmount()
                                    self.totalAmountLabel.countFromCurrentValueTo(CGFloat(totalAmount), withDuration: 1.5)
                                }
                            }
                        }
                    }
                    //When personal subs are activated/deactivated
                    if change.type == .modified{
                        let updatedData = change.document.data()
                        let subID = updatedData["subid"] as! String
                        if updatedData["status"] as! Bool != true{
                            for sub in self.individualSubs{
                                if subID == sub.id{
                                    if sub.status == true {
                                        sub.status = false
                                        self.individualSubs.removeAll { $0.id == subID }
                                    }
                                }
                            }
                        } else {
                            let imageRef = updatedData["company"] as! String
                            let dateRef = updatedData["nextdate"] as! String
                            let remaining = self.calculateDatesRemaining(dateString: dateRef)
                            let starsRef = storageRef.child("Images/" + imageRef  + ".jpg")
                            starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                                let logoImage = UIImage(data: data!)!
                                self.individualSubs.append(Subscription(id: updatedData["subid"] as! String , name: updatedData["company"] as! String, image: logoImage, plan: updatedData["plan"] as! String, price: updatedData["price"] as! Int, genre: updatedData["genre"] as! String, status: updatedData["status"] as! Bool, date: updatedData["date"] as! String, nextdate: updatedData["nextdate"] as! String, remainingDays: remaining)!)
                                DispatchQueue.main.async {
                                    self.sortSubscriptions()
                                    self.inviTableView.reloadData()
                                    let totalAmount = self.calculateTotalAmount()
                                    self.totalAmountLabel.countFromCurrentValueTo(CGFloat(totalAmount), withDuration: 1.5)

                                }
                            }
                        }
         
                        self.inviTableView.reloadData()
                        let totalAmount = self.calculateTotalAmount()
                        self.totalAmountLabel.countFromCurrentValueTo(CGFloat(totalAmount), withDuration: 1.5)
                    }
                    //When personal subs are removed
                    if change.type == .removed{
                        let removedData = change.document.data()
                        let removedSubId = removedData["subid"] as! String
                        for sub in self.individualSubs{
                            if removedSubId == sub.id{
                                self.individualSubs.removeAll { $0.id == removedSubId }
                                self.sortSubscriptions()
                                self.inviTableView.reloadData()
                                let totalAmount = self.calculateTotalAmount()
                                self.totalAmountLabel.countFromCurrentValueTo(CGFloat(totalAmount), withDuration: 1.5)
                            }
                        }
                    }
                })
            }
        }
        
        //Group query - queries groups saved in user table and finds the respective groups in the groups table
        //And for every group creates a SnapshotListener that listens for any changes made within the subs in the selected groups
        db.collection("users").document(userID).collection("Groups").addSnapshotListener { (groupsSnapshot, error) in
            if let error = error {
                print("Error getting change: \(error)")
            } else {
                groupsSnapshot?.documentChanges.forEach({ (GroupChange) in
                    let newGroup = GroupChange.document.data()
                    let groupID = newGroup["gid"] as! String
                    self.db.collection("groups").document(groupID).collection("Subs").addSnapshotListener { (groupSubSnapshot, error) in
                        if let error = error{
                            print("Error getting change: \(error)")
                        } else {
                            groupSubSnapshot?.documentChanges.forEach({ (groupSubChange) in
                                //When subs in groups are added
                                if groupSubChange.type == .added{
                                    let newSubChange = groupSubChange.document.data()
                                    let companyName = newSubChange["company"] as! String
                                    let subPlan = newSubChange["plan"] as! String
                                    let subPrice = newSubChange["price"] as! Int
                                    self.totalExpense += subPrice
                                    let subGenre = newSubChange["genre"] as! String
                                    let subStatus = newSubChange["status"] as! Bool
                                    let subID = newSubChange["subid"] as! String
                                    let subDate = newSubChange["date"] as! String
                                    let subNextDate = newSubChange["nextdate"] as! String
                                    let starsRef = storageRef.child("Images/" + companyName  + ".jpg")
                                    let remaining = self.calculateDatesRemaining(dateString: subNextDate)
                                    starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                                        if let error = error {
                                          print("Error \(error)")
                                        } else {
                                            let logoImage = UIImage(data: data!)!
                                            if subStatus == true {
                                                self.groupSubs.append(Subscription(id:subID, name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate, nextdate: subNextDate, remainingDays: remaining)!)
                                            }
                                            DispatchQueue.main.async {
                                                self.sortSubscriptions()
                                                self.groupTableView.reloadData()
                                                //self.totalExpense += self.calculateTotalAmount(allSubs: self.groupSubs)
                                                //Self counting label from this repo: https://github.com/EFPrefix/EFCountingLabel
                                                let totalAmount = self.calculateTotalAmount()
                                                self.totalAmountLabel.countFromCurrentValueTo(CGFloat(totalAmount), withDuration: 1.5)
                                            }
                                        }
                                    }
                                }
                                //When subs in groups are activated/deactivated
                                if groupSubChange.type == .modified{
                                    let updatedData = groupSubChange.document.data()
                                    let subID = updatedData["subid"] as! String
                                    if updatedData["status"] as! Bool != true{
                                                for sub in self.groupSubs{
                                                    if subID == sub.id{
                                                        if sub.status == true {
                                                            sub.status = false
                                                            self.groupSubs.removeAll { $0.id == subID }
                                                        }
                                                    }
                                                }
                                        
                                               } else {
                                                let imageRef = updatedData["company"] as! String
                                                let dateRef = updatedData["nextdate"] as! String
                                                let remaining = self.calculateDatesRemaining(dateString: dateRef)
                                                let starsRef = storageRef.child("Images/" + imageRef  + ".jpg")
                                                starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                                                    let logoImage = UIImage(data: data!)!
                                                    self.groupSubs.append(Subscription(id: updatedData["subid"] as! String , name: updatedData["company"] as! String, image: logoImage, plan: updatedData["plan"] as! String, price: updatedData["price"] as! Int, genre: updatedData["genre"] as! String, status: updatedData["status"] as! Bool, date: updatedData["date"] as! String, nextdate: updatedData["nextdate"] as! String, remainingDays: remaining)!)
                                                    DispatchQueue.main.async {
                                                        self.sortSubscriptions()
                                                        self.groupTableView.reloadData()
                                                        let totalAmount = self.calculateTotalAmount()
                                                        self.totalAmountLabel.countFromCurrentValueTo(CGFloat(totalAmount), withDuration: 1.5)
                                                    }
                                                }
                                    }
                                    self.groupTableView.reloadData()
                                    let totalAmount = self.calculateTotalAmount()
                                    self.totalAmountLabel.countFromCurrentValueTo(CGFloat(totalAmount), withDuration: 1.5)
                                }
                                //When subs in groups are removed
                                if groupSubChange.type == .removed{
                                    let removedData = groupSubChange.document.data()
                                    let removedSubId = removedData["subid"] as! String
                                    for sub in self.groupSubs{
                                        if removedSubId == sub.id{
                                            self.groupSubs.removeAll { $0.id == removedSubId }
                                            self.sortSubscriptions()
                                            self.groupTableView.reloadData()
                                            let totalAmount = self.calculateTotalAmount()
                                            self.totalAmountLabel.countFromCurrentValueTo(CGFloat(totalAmount), withDuration: 1.5)
                                        }
                                    }
                                }
                            })
                        }
                    }
                })
            }
        }
    }
    
    
    func calculateTotalAmount() -> Int{
        var totalamount = 0
        for sub in individualSubs{
            if sub.status == true{
                totalamount = sub.price + totalamount
            }
        }
        for sub in groupSubs{
            if sub.status == true{
                totalamount = sub.price + totalamount
            }
        }
        return totalamount
    }
    
    func calculateDatesRemaining(dateString: String) -> Int{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "MM/dd/yy"
        let date = dateFormatter.date(from: dateString)
        let currentDate = Date()
        let calender = Calendar.current
        let daysRemaining = calender.dateComponents([.day], from: currentDate, to: date!).day
        
        return daysRemaining!
    }

    
    func sortSubscriptions(){
        individualSubs.sort { (Subscription1, Subscription2) -> Bool in
            if Subscription1.remainingDays != Subscription2.remainingDays{
                return Subscription1.remainingDays < Subscription2.remainingDays
            } else {
                return Subscription1.name < Subscription2.name
            }
        }
        groupSubs.sort { (Subscription1, Subscription2) -> Bool in
            if Subscription1.remainingDays != Subscription2.remainingDays{
                return Subscription1.remainingDays < Subscription2.remainingDays
            } else {
                return Subscription1.name < Subscription2.name
            }
        }
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case inviTableView:
            return individualSubs.count
        case groupTableView:
            return groupSubs.count
        default:
            return 1
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
        let cell = UITableViewCell()
        switch tableView {
        case inviTableView:
            let inviCell = inviTableView.dequeueReusableCell(withIdentifier: "inviCell", for: indexPath) as! TableViewCell
            inviCell.homeIndvidualCostLabel.text = String(individualSubs[indexPath.section].price) + " dkk,-"
            inviCell.homeIndvidualImage.image = individualSubs[indexPath.section].image
            inviCell.homeIndvidualRemainingLabel.text = String(individualSubs[indexPath.section].remainingDays)
            inviCell.layer.cornerRadius = 8
            inviCell.clipsToBounds = true
            return inviCell
        case groupTableView:
            let grpCell = groupTableView.dequeueReusableCell(withIdentifier: "grpCell", for: indexPath) as! TableViewCell
            grpCell.homeGroupCostLabel.text = String(groupSubs[indexPath.section].price) + " dkk,-"
            grpCell.homeGroupImage.image = groupSubs[indexPath.section].image
            grpCell.homeGroupRemainingLabel.text = String(groupSubs[indexPath.section].remainingDays)
            grpCell.layer.cornerRadius = 8
            grpCell.clipsToBounds = true
            return grpCell
        default:
            return cell
        }

    }
}

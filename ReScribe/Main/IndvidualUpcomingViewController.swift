//
//  IndvidualUpcomingViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 22/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit
import Firebase
import EFCountingLabel

var datePicker:UIDatePicker = UIDatePicker()
let toolBar = UIToolbar()

class IndvidualUpcomingViewController: UIViewController {
    @IBOutlet weak var addButtonUI: UIButton!
    @IBOutlet weak var infotabView: UIView!
    @IBOutlet weak var indvidualTableView: UITableView!
    @IBOutlet weak var viewTableView: UIView!
    @IBOutlet weak var individualAmount: EFCountingLabel!
    
    let storage = Storage.storage()
    let userID = Auth.auth().currentUser!.uid
    let db = Firestore.firestore()
    var individualSubs = [Subscription]()
    var root = "personal"
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.addButtonUI.round(corners: [.bottomLeft, .bottomRight, .topRight, .topLeft], cornerRadius: 20)
        self.viewTableView.round(corners: .allCorners, cornerRadius: 10)
        individualAmount.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 3)

        let storageRef = storage.reference()
        db.collection("users").document(userID).collection("Subs").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error getting change: \(error)")
            } else {
                let newDocument = snapshot
                newDocument?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let newData = change.document.data()
                        let companyName = newData["company"] as! String
                        let subPlan = newData["plan"] as! String
                        let subPrice = newData["price"] as! Int
                        let subGenre = newData["genre"] as! String
                        let subStatus = newData["status"] as! Bool
                        let subDate = newData["date"] as! String
                        let subID = newData["subid"] as! String
                        let subNextDate = newData["nextdate"] as! String
                        let starsRef = storageRef.child("Images/" + companyName  + ".jpg")
                        let remaining = self.calculateDatesRemaining(dateString: subNextDate)
                        starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                            if let error = error {
                              print("Error \(error)")
                            } else {
                                let logoImage = UIImage(data: data!)!
                                if subStatus == true{
                                    self.individualSubs.append(Subscription(id: subID, name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate, nextdate: subNextDate, remainingDays: remaining)!)
                                } else {
                                    self.individualSubs.append(Subscription(id: subID, name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate, nextdate: subNextDate, remainingDays: 1000)!)
                                }
                                DispatchQueue.main.async {
                                    self.sortSubscriptions()
                                    self.indvidualTableView.reloadData()
                                    let individualSubAmount = self.calculateTotalAmount(allSubs: self.individualSubs)
                                    //Self counting label from this repo: https://github.com/EFPrefix/EFCountingLabel
                                    self.individualAmount.countFromZeroTo(CGFloat(individualSubAmount), withDuration: 1.5)
                                    self.individualAmount.completionBlock = { () in
                                        self.individualAmount.text = String(individualSubAmount)
                                    }
                                }
                            }
                        }
                    }
                    
                    if change.type == .modified{
                        let updatedData = change.document.data()
                        for sub in self.individualSubs{
                            if updatedData["subid"] as! String == sub.id{
                                if sub.status == true {
                                    sub.status = false
                                    sub.remainingDays = 1000
                                } else {
                                    sub.status = true
                                    sub.date = updatedData["date"] as! String
                                    let updatedremaining = updatedData["nextdate"] as! String
                                    sub.remainingDays = self.calculateDatesRemaining(dateString: updatedremaining)
                                }
                            }
                        }
                        
                        self.sortSubscriptions()
                        self.indvidualTableView.reloadData()
                        let newSubAmount = self.calculateTotalAmount(allSubs: self.individualSubs)
                        self.individualAmount.countFromCurrentValueTo(CGFloat(newSubAmount), withDuration: 1.5)
                        self.individualAmount.completionBlock = { () in
                            self.individualAmount.text = String(newSubAmount)
                        }
                    }
                    
                    if change.type == .removed{
                        let removedData = change.document.data()
                        let removedSubId = removedData["subid"] as! String
                        for sub in self.individualSubs{
                            if removedSubId == sub.id{
                                self.individualSubs.removeAll { $0.id == removedSubId }
                                self.sortSubscriptions()
                                self.indvidualTableView.reloadData()
                                let newSubAmount = self.calculateTotalAmount(allSubs: self.individualSubs)
                                self.individualAmount.countFromCurrentValueTo(CGFloat(newSubAmount), withDuration: 1.5)
                                self.individualAmount.completionBlock = { () in
                                    self.individualAmount.text = String(newSubAmount)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func calculateTotalAmount(allSubs: [Subscription]) -> Int{
        var totalamount = 0
        for sub in allSubs{
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
    }
    
}

extension IndvidualUpcomingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowIndex = indexPath.section

        
        performSegue(withIdentifier: "viewSubs", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSubs"{
            let vc = segue.destination as! ViewSubscriptionViewController
            vc.selectedSub = individualSubs[rowIndex]
        } else {
            let vc2 = segue.destination as! SubscriptionAddViewController
            vc2.root = root
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return individualSubs.count
     }

     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return cellHeight
     }

     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let headerView = UIView()
         headerView.backgroundColor = UIColor.clear
         return headerView
     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = indvidualTableView.dequeueReusableCell(withIdentifier: "upcomingPayments", for: indexPath) as! TableViewCell
        
        
        if individualSubs[indexPath.section].status != true{
            cell.upcomingTimeLabel.text = "Deactivated"
            cell.upcomingCostLabel.text = " "
            } else {
            cell.upcomingCostLabel.text = String(individualSubs[indexPath.section].price) + ",-  dkk"
            cell.upcomingTimeLabel.text = String(individualSubs[indexPath.section].remainingDays) + "    days"
        }
        cell.upcomingImage.image = individualSubs[indexPath.section].image
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

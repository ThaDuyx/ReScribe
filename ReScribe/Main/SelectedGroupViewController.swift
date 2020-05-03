//
//  SelectedGroupViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 28/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit
import Firebase
import EFCountingLabel

class SelectedGroupViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var groupExpenses: EFCountingLabel!
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    let storage = Storage.storage()
    var root = "groups"
    var selectedGroup : Group?
    var groupSubscriptions = [Subscription]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.round(corners: .allCorners, cornerRadius: 20)
        self.infoView.round(corners: [.bottomRight, .bottomLeft], cornerRadius: 20)
        self.addButton.round(corners: .allCorners, cornerRadius: 20)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(netHex: 0x353535)
        print(selectedGroup!.gid)
        let storageRef = storage.reference()
        db.collection("groups").document(selectedGroup!.gid).collection("Subs").addSnapshotListener { (snapshot, error) in
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
                                    self.groupSubscriptions.append(Subscription(id: subID, name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate, nextdate: subNextDate, remainingDays: remaining)!)
                                } else {
                                    self.groupSubscriptions.append(Subscription(id: subID, name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate, nextdate: subNextDate, remainingDays: 1000)!)
                                }
                                DispatchQueue.main.async {
                                    self.paymentTableView.reloadData()
                                    let totalGroupExpense = self.calculateTotalAmount(allSubs: self.groupSubscriptions)
                                    self.groupExpenses.countFrom(0, to: CGFloat(totalGroupExpense))
                                }
                            }
                        }
                    }
                    
                    if change.type == .modified{
                        let updatedData = change.document.data()
                        for sub in self.groupSubscriptions{
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
                        
                        //self.sortSubscriptions()
                        self.paymentTableView.reloadData()
                        let newSubAmount = self.calculateTotalAmount(allSubs: self.groupSubscriptions)
                        self.groupExpenses.countFromCurrentValueTo(CGFloat(newSubAmount), withDuration: 1.5)
                        self.groupExpenses.completionBlock = { () in
                            self.groupExpenses.text = String(newSubAmount)
                        }
                    }
                    
                    if change.type == .removed{
                        let removedData = change.document.data()
                        let removedSubId = removedData["subid"] as! String
                        for sub in self.groupSubscriptions{
                            if removedSubId == sub.id{
                                self.groupSubscriptions.removeAll { $0.id == removedSubId }
                                //self.sortSubscriptions()
                                self.paymentTableView.reloadData()
                                let newSubAmount = self.calculateTotalAmount(allSubs: self.groupSubscriptions)
                                self.groupExpenses.countFromCurrentValueTo(CGFloat(newSubAmount), withDuration: 1.5)
                                self.groupExpenses.completionBlock = { () in
                                    self.groupExpenses.text = String(newSubAmount)
                                }
                            }
                        }
                    }
                })
            }
        }
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
    
    func calculateTotalAmount(allSubs: [Subscription]) -> Int{
        var totalamount = 0
        for sub in allSubs{
            if sub.status == true{
                totalamount = sub.price + totalamount
            }
        }
        return totalamount
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "viewGrpSub"{
            let vc = segue.destination as! SubscriptionAddViewController
            vc.root = root
            vc.groupID = selectedGroup!.gid
        } else {
            let vc = segue.destination as! ViewSubscriptionViewController
            vc.selectedSub = groupSubscriptions[rowIndex]
            vc.root = root
            vc.groupID = selectedGroup!.gid
        }
    }
}

extension SelectedGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowIndex = indexPath.section
        performSegue(withIdentifier: "viewGrpSub", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return groupSubscriptions.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupPayment", for: indexPath) as! TableViewCell
        
        if groupSubscriptions[indexPath.section].status != true{
            cell.selectedGroupTimeLabel.text = "Deativated"
            cell.selectedGroupCostLabel.text = " "
        } else {
            cell.selectedGroupTimeLabel.text = String(groupSubscriptions[indexPath.section].remainingDays)
            cell.selectedGroupCostLabel.text = String(groupSubscriptions[indexPath.section].price)
        }
        cell.selectedGroupImage.image = groupSubscriptions[indexPath.section].image


        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

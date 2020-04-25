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

let daysArr = ["1","2"]
let nnameArr = ["155", "278"]
let cellSpacingHeight: CGFloat = 5

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
                        let starsRef = storageRef.child("Images/" + companyName  + ".jpg")
                        starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                            if let error = error {
                              print("Error \(error)")
                            } else {
                                let logoImage = UIImage(data: data!)!
                                self.individualSubs.append(Subscription(id: subID, name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate)!)
                                DispatchQueue.main.async {
                                    self.indvidualTableView.reloadData()
                                    let individualSubAmount = self.calculateTotalAmount(allSubs: self.individualSubs)
                                    //Self counting label from this repo: https://github.com/EFPrefix/EFCountingLabel
                                    self.individualAmount.countFromZeroTo(CGFloat(individualSubAmount), withDuration: 1.5)
                                    self.individualAmount.completionBlock = { () in
                                        self.individualAmount.text = String(individualSubAmount) + " dkk,-"
                                    }

                                    //let test = self.calculateRemainingDays(date: subDate)
                                    //print(test)
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
                                } else {
                                    sub.status = true
                                }
                            }
                        }
                        self.indvidualTableView.reloadData()
                        let newSubAmount = self.calculateTotalAmount(allSubs: self.individualSubs)
                        self.individualAmount.countFromCurrentValueTo(CGFloat(newSubAmount), withDuration: 1.5)
                        self.individualAmount.completionBlock = { () in
                            self.individualAmount.text = String(newSubAmount) + " dkk,-"
                        }
                    }
                    if change.type == .removed{
                        let removedData = change.document.data()
                        print(removedData)
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
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return individualSubs.count
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
        
        
        if individualSubs[indexPath.section].status != true{
            cell.timeLabel.text = "Deactivated"
            cell.costLabel.text = " "
            } else {
            cell.costLabel.text = String(individualSubs[indexPath.section].price) + ",-  dkk"
            cell.timeLabel.text = individualSubs[indexPath.section].date + "    days"
        }
        cell.imageLabel.image = individualSubs[indexPath.section].image
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

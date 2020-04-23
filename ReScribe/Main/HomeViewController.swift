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

let nameArr = ["Viaplay", "Netflix", "HBO", "Youtube", "CBS", "Twitch", "Cmore", "D-play", "Spotify", "Apple Music", "World of Warcraft", "Apple TV", "Discord", "Strava", "Disney+", "Amazon Prime"]

class HomeViewController: UIViewController {
   
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var inviView: UIView!
    @IBOutlet weak var infotabView: UITableView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var inviTableView: UITableView!
    @IBOutlet weak var groupTableView: UITableView!
    
    let storage = Storage.storage()
    let userID = Auth.auth().currentUser!.uid
    let db = Firestore.firestore()
    var individualSubs = [Subscription]()
    var firstload = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inviView.round(corners: [.allCorners], cornerRadius: 10)
        self.groupView.round(corners: [.allCorners], cornerRadius: 10)
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        
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
                        let starsRef = storageRef.child("Images/" + companyName  + ".jpg")
                        starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                            if let error = error {
                              print("Error \(error)")
                            } else {
                                let logoImage = UIImage(data: data!)!
                                self.individualSubs.append(Subscription(name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate)!)
                                DispatchQueue.main.async {
                                    self.inviTableView.reloadData()
                                    self.totalAmountLabel.text = String(self.calculateTotalAmount(allSubs: self.individualSubs)) + " dkk,-"
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
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return individualSubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inviCell = inviTableView.dequeueReusableCell(withIdentifier: "inviCell", for: indexPath) as! HomeInviTableViewCell
        inviCell.costLabel.text = String(individualSubs[indexPath.row].price)
        inviCell.imageLabel.image = individualSubs[indexPath.row].image
        inviCell.remainingLabel.text = individualSubs[indexPath.row].date
        
        return inviCell
    }
}


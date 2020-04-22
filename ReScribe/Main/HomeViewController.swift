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
let arrayOfSome = ["Viaplay", "Netflix"]

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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inviView.round(corners: [.allCorners], cornerRadius: 10)
        self.groupView.round(corners: [.allCorners], cornerRadius: 10)
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        
        let storageRef = storage.reference()
        db.collection("users").document(userID).collection("Subs").getDocuments { (snapShot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapShot!.documents {
                    let queryData = document.data()
                    let imageDirectory = queryData["company"] as! String
                    let starsRef = storageRef.child("Images/" + imageDirectory  + ".jpg")
                    starsRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                        if let error = error {
                          print("Error \(error)")
                        } else {
                            let logoImage = UIImage(data: data!)!
                            let companyName = queryData["company"] as! String
                            let subPlan = queryData["plan"] as! String
                            let subPrice = queryData["price"] as! Int
                            let subGenre = queryData["genre"] as! String
                            let subStatus = queryData["status"] as! Bool
                            let subDate = queryData["date"] as! String
                            
                            self.individualSubs.append(Subscription(name: companyName, image: logoImage, plan: subPlan, price: subPrice, genre: subGenre, status: subStatus, date: subDate)!)
                            DispatchQueue.main.async {
                                //self.inviCell.reloadData()
                                self.totalAmountLabel.text = String(self.calculateTotalAmount(allSubs: self.individualSubs)) + " dkk,-"
                            }
                        }
                    }
                }
            }
        }
    }
    func calculateTotalAmount(allSubs: [Subscription]) -> Int{
        var totalamount = 0
        for sub in allSubs{
            totalamount = sub.price + totalamount
        }
        return totalamount
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inviCell = inviTableView.dequeueReusableCell(withIdentifier: "inviCell", for: indexPath) as! HomeInviTableViewCell
        let grpCell = groupTableView.dequeueReusableCell(withIdentifier: "grpCell", for: indexPath) as! HomeGrpTableViewCell
        inviCell.costLabel.text = nameArr[indexPath.row]
        grpCell.costLabel.text = ""
        return inviCell
    }
}


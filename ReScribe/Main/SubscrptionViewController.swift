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
    @IBOutlet weak var saveBtn: UIButton!

    
    
    var headerName = ""
    var subPlans = [Plan]()
    
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
        
        //Genre query
        let db = Firestore.firestore()
        db.collection("Subscriptions").document(headerName).getDocument { (document, err) in
            if let data = document?.data(){
                let genreString = data["Genre"] as! String
                self.genreLabel.text = genreString
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
    
    func instanceOfDate(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneTapped))
        toolbar.setItems([doneBtn], animated: true)
        datePick.inputAccessoryView = toolbar
        datePick.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    
    @objc func doneTapped() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        datePick.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        planView.reloadData()
    }
}

extension SubscriptionViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = planView.dequeueReusableCell(withIdentifier: "plansCell", for: indexPath) as! selectedPlanTableViewCell
        
        /*cell.textLabel?.text = subPlans[indexPath.row].name
        cell.detailTextLabel?.text = String(subPlans[indexPath.row].price)*/
        cell.packagePlanLabel.text = subPlans[indexPath.row].name
        cell.amountLabel.text = String(subPlans[indexPath.row].price)
        return cell
    }
}

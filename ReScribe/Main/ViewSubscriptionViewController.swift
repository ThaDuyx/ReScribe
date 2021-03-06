//
//  ViewSubscriptionViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 23/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit
import Firebase

class ViewSubscriptionViewController: UIViewController {
    @IBOutlet weak var infotab: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    var root = ""
    var groupID = ""
    //Buttons
    @IBOutlet weak var onOffBtn: UIButton!
    @IBAction func onOffBtnTapped(_ sender: Any) {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        if selectedSub?.status == true{
            if root == "personal"{
                db.collection("users").document(userID).collection("Subs").document(selectedSub!.id).setData(["status" : false], merge: true) { (error) in
                    if error != nil{
                        print("Oops")
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            } else if root == "groups"{
                db.collection("groups").document(groupID).collection("Subs").document(selectedSub!.id).setData(["status" : false], merge: true) { (error) in
                    if error != nil{
                        print("Oops")
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            } else {
                print("Something went wrong")
            }
        } else {
            
            //The following code taken from:
            //https://stackoverflow.com/a/56607279/11614540
            //With small adjustments
            let myDatePicker: UIDatePicker = UIDatePicker()
            myDatePicker.timeZone = .current
            myDatePicker.frame = CGRect(x: 0, y: 15, width: 270, height: 200)
            myDatePicker.datePickerMode = .date
            let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n Pick a new payment date", message: nil, preferredStyle: .alert)
            alertController.view.addSubview(myDatePicker)
            let selectAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                
                //Own code
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                let newDate = dateFormatter.string(from: myDatePicker.date)
                let calender = Calendar.current
                let nextPaymentDate = calender.date(byAdding: .day, value: 31, to: myDatePicker.date)
                let updateNextDate = dateFormatter.string(from: nextPaymentDate!)
                
                if self.root == "personal"{
                    db.collection("users").document(userID).collection("Subs").document(self.selectedSub!.id).setData(["status" : true, "date":newDate, "nextdate":updateNextDate], merge: true) { (error) in
                        if error != nil {
                            print("Oops")
                        } else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                } else if self.root == "groups"{
                    db.collection("groups").document(self.groupID).collection("Subs").document(self.selectedSub!.id).setData(["status" : true, "date":newDate, "nextdate":updateNextDate], merge: true) { (error) in
                        if error != nil {
                            print("Oops")
                        } else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
                //Own code ends
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
            //--------------------------------------------
            //Taken code ends
        }
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: "Remove", message: "Are you sure you want to delete this subscription?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            let db = Firestore.firestore()
            let userID = Auth.auth().currentUser!.uid
            if self.root == "personal" {
                db.collection("users").document(userID).collection("Subs").document(self.selectedSub!.id).delete()
            } else if self.root == "groups" {
                db.collection("groups").document(self.groupID).collection("Subs").document(self.selectedSub!.id).delete()
            }
            self.navigationController?.popToRootViewController(animated: true)
            print("Deleting")
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          print("Handle Cancel Logic here")
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    //Labels
    @IBOutlet weak var selectedSubImage: UIImageView!
    @IBOutlet weak var selectedSubPrice: UILabel!
    @IBOutlet weak var selectedSubHeader: UILabel!
    @IBOutlet weak var selectedSubGenre: UILabel!
    @IBOutlet weak var selectedSubDate: UILabel!
    @IBOutlet weak var selectedSubStatus: UILabel!
    @IBOutlet weak var selectedSubRemainingDays: UILabel!
    
    //Passed object from segue
    var selectedSub : Subscription?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infotab.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(netHex: 0x353535)
        self.backgroundView.round(corners: .allCorners, cornerRadius: 10)
        
        
        selectedSubImage.image = selectedSub?.image
        selectedSubHeader.text = selectedSub?.name
        selectedSubGenre.text = selectedSub?.genre
        selectedSubDate.text = selectedSub?.date
        selectedSubPrice.text = String(selectedSub!.price)
        if selectedSub?.status == true {
            selectedSubStatus.text = "Active"
            selectedSubDate.text = selectedSub?.date
            selectedSubRemainingDays.text = String(selectedSub!.remainingDays)
            onOffBtn.setTitle("Deactivate", for: .normal)
        } else{
            selectedSubStatus.text = "Deactivated"
            selectedSubDate.text = "NA"
            selectedSubRemainingDays.text = "NA"
            onOffBtn.setTitle("Activate", for: .normal)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension ViewSubscriptionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowIndex = indexPath.row
        
        performSegue(withIdentifier: "viewSubs", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "plansCell", for: indexPath) as! TableViewCell
        cell.viewSubscriptionAmountLabel.text = String(selectedSub!.price) + ",-  dkk"
        cell.viewSubscriptionPackageLabel.text = selectedSub?.plan
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

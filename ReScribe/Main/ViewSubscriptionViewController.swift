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
    @IBOutlet weak var tableView: UITableView!
    
    //Buttons
    @IBOutlet weak var onOffBtn: UIButton!
    @IBAction func onOffBtnTapped(_ sender: Any) {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        if selectedSub?.status == true{
            db.collection("users").document(userID).collection("Subs").document(selectedSub!.id).setData(["status" : false], merge: true) { (error) in
                if error != nil{
                    print("Oops")
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            db.collection("users").document(userID).collection("Subs").document(selectedSub!.id).setData(["status" : true], merge: true) { (error) in
                if error != nil {
                    print("Oops")
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: "Remove", message: "Are you sure you want to delete this subscription?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            let db = Firestore.firestore()
            let userID = Auth.auth().currentUser!.uid
            db.collection("users").document(userID).collection("Subs").document(self.selectedSub!.id).delete()
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
    
    //Passed object from segue
    var selectedSub : Subscription?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infotab.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(netHex: 0x353535)
        
        selectedSubImage.image = selectedSub?.image
        selectedSubHeader.text = selectedSub?.name
        selectedSubGenre.text = selectedSub?.genre
        selectedSubDate.text = selectedSub?.date
        selectedSubPrice.text = String(selectedSub!.price)
        if selectedSub?.status == true {
            selectedSubStatus.text = "Active"
            onOffBtn.setTitle("Deactivate", for: .normal)
        } else{
            selectedSubStatus.text = "Deactivated"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "plansCell", for: indexPath) as! ViewSubscriptionTableViewCell
        cell.amountLabel.text = String(selectedSub!.price) + ",-  dkk"
        cell.packagePlanLabel.text = selectedSub?.plan
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
}

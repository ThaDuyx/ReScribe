//
//  RegisterViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 06/05/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol UserCreated {
    func whenUserIsCreated(email: String, password: String)
}

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var confirmPassLabel: UITextField!
    @IBOutlet weak var passLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    var loginViewController:LoginViewController?
    var delegate:UserCreated?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerBtn.round(corners: .allCorners, cornerRadius: 10)
        emailLabel.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x9e9e9e)])
        passLabel.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x9e9e9e)])
        confirmPassLabel.attributedPlaceholder = NSAttributedString(string: "Confirm password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x9e9e9e)])

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginViewController{
            vc.insertEmail.text = emailLabel.text
            vc.insertPass.text = confirmPassLabel.text
        }
    }

    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func enterTapped(_ sender: Any){
        let password = passLabel.text!
        let confirmPassword = confirmPassLabel.text!
        let email = emailLabel.text!
        if password != confirmPassword {
            let refreshAlert = UIAlertController(title: "Error", message: "Password and Password confirm is not the same", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }else if password == "" {
            let refreshAlert = UIAlertController(title: "Error", message: "Password can't be empty!", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        } else if email == "" {
            let refreshAlert = UIAlertController(title: "Error", message: "Email can't be empty!", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }else {
            //Her skal vi skrive det kode som skal køres når man har skrevet email, password og alt er i orden
            Auth.auth().createUser(withEmail: email, password: confirmPassword) { (createUserSnapshot, error) in
                if let error = error {
                    print(error)
                } else {
                    self.delegate?.whenUserIsCreated(email: email, password: confirmPassword)
                    let db = Firestore.firestore()
                    db.collection("users").document((createUserSnapshot?.user.uid)!).setData(["name":email, "uid":(createUserSnapshot?.user.uid)!])
                    self.navigationController?.popViewController(animated: true)

                }
            }
        }
    }
}

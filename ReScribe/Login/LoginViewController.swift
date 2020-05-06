//
//  LoginViewController.swift
//  ReScribe
//
//  Created by Simon Andersen on 09/03/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController, UserCreated {
    func whenUserIsCreated(email: String, password: String) {
        self.insertEmail.text = email
        self.insertPass.text = password

    }
    
    @IBOutlet weak var insertEmail: UITextField!
    @IBOutlet weak var insertPass: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var databaseLoad: UIActivityIndicatorView!
    @IBOutlet weak var viewLogin: UIView!
    var errorOcurred = false
    var newUserEmail = ""
    var newUserPass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBtn.round(corners: .allCorners, cornerRadius: 10)
        insertEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x9e9e9e)])
        insertPass.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x9e9e9e)])
        if newUserEmail != ""{
            self.insertEmail.text = newUserEmail
            self.insertPass.text = newUserPass
            print(newUserPass)
            print(newUserEmail)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let secondVC: RegisterViewController = segue.destination as! RegisterViewController
            secondVC.delegate = self
    }

    @IBAction func loginTapped(_ sender: Any) {
        
        if (insertEmail.text?.isEmpty)! || (insertPass.text?.isEmpty)! {
            let refreshAlert = UIAlertController(title: "Error", message: "Password or email cant be empty!", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        } else {
            databaseLoad.alpha = 1
            databaseLoad.startAnimating()
            
            let email = self.insertEmail.text!
            let password = self.insertPass.text!
            
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    let refreshAlert = UIAlertController(title: "Error", message: "Password or email is wrong!", preferredStyle: UIAlertController.Style.alert)
                    refreshAlert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { (action: UIAlertAction!) in
                        
                    }))
                    self.present(refreshAlert, animated: true, completion: nil)
                    self.databaseLoad.stopAnimating()
                    self.databaseLoad.alpha = 0
                } else {
                    
                    self.databaseLoad.stopAnimating()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "mainVC")
                   
                    self.view.window?.rootViewController = vc
                    self.view.window?.makeKeyAndVisible()
                    
                }
            }
            
        }
    }
}

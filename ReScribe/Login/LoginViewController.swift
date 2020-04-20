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

class LoginViewController: UIViewController {

    @IBOutlet weak var insertEmail: UITextField!
    @IBOutlet weak var insertPass: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var databaseLoad: UIActivityIndicatorView!
    @IBOutlet weak var viewLogin: UIView!
    var errorOcurred = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginTapped(_ sender: Any) {

        if (insertEmail.text?.isEmpty)! || (insertPass.text?.isEmpty)! {
            errorLabel.alpha = 1
            errorLabel.text = "email/password cant be empty"
        } else {
            errorLabel.text = ""
            databaseLoad.alpha = 1
            databaseLoad.startAnimating()
            
            let email = self.insertEmail.text!
            let password = self.insertPass.text!
            
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    self.errorLabel.alpha = 1
                    self.errorLabel.text = error!.localizedDescription
                    self.databaseLoad.stopAnimating()
                    self.databaseLoad.alpha = 0
                } else {
                    
                    self.databaseLoad.stopAnimating()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "mainVC")
                   
                    self.view.window?.rootViewController = vc
                    self.view.window?.makeKeyAndVisible()
                    
                    /*let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeVC") as? HomeViewController
                    self.view.window?.rootViewController = homeViewController
                    self.view.window?.makeKeyAndVisible()*/
                }
            }
            
        }
    }
}

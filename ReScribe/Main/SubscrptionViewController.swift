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
    
    let storage = Storage.storage()
    @IBOutlet weak var infotabView: UIView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var headerForSub: UILabel!
    @IBOutlet weak var imageForSub: UIImageView!
    var headerName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerForSub.text = headerName
        let storageRef = storage.reference()
        let starsRef = storageRef.child("Images/" + headerName + ".jpg")
        let imageView: UIImageView = self.imageForSub
        let placeholderImage = UIImage(named: "Netflix.jpg")
        imageView.sd_setImage(with: starsRef, placeholderImage: placeholderImage)
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
    }
        override func viewWillDisappear(_ animated: Bool) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
}

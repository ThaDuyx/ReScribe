//
//  dbsubs.swift
//  ReScribe
//
//  Created by Simon Andersen on 11/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class dbsubs: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let db = Firestore.firestore()
        
        db.collection("Subscription").getDocuments { (snapshot, error) in
            if error == nil && snapshot != nil {
                for document in snapshot!.documents{
                    let documentData = document.data()
                }
        }
        }
        
        
    }
    
    
    
}

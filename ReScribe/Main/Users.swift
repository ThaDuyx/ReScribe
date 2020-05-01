//
//  Users.swift
//  ReScribe
//
//  Created by Simon Andersen on 29/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation

class User {
    var uid: String
    var name: String
    
    init?(uid: String, name: String){
        self.uid = uid
        self.name = name
    }
}

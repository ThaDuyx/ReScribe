//
//  Groups.swift
//  ReScribe
//
//  Created by Simon Andersen on 29/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation

import UIKit

class Group {
    var gid:String
    var name:String
    var subcription = [Subscription]()
    var group = [Group]()
    
    init?(id: String, name: String, subcription: [Subscription], group: [Group]){
        self.gid = id
        self.name = name
        self.subcription = subcription
        self.group = group
    }
}


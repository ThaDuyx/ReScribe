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

    init?(id: String, name: String){
        self.gid = id
        self.name = name
    }
}


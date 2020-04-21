//
//  Plans.swift
//  ReScribe
//
//  Created by Simon Andersen on 20/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation
import UIKit

class Plan {
    var name: String
    var price: Int
    
    init?(name: String, price: Int){
        self.name = name
        self.price = price
    }
}

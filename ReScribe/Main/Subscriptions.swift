//
//  Subscriptions.swift
//  ReScribe
//
//  Created by Simon Andersen on 14/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import Foundation
import UIKit

class Subscription {
    var name: String
    var image: UIImage
    var plan: String
    var price: Int
    var genre: String
    var status: Bool
    var date: String
    
    init?(name: String, image: UIImage, plan: String, price: Int, genre: String, status: Bool, date: String){
        self.name = name
        self.plan = plan
        self.image = image
        self.price = price
        self.genre = genre
        self.status = status
        self.date = date
    }
}

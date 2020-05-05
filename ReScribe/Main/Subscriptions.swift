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
    var id: String
    var name: String
    var image: UIImage
    var plan: String
    var price: Int
    var genre: String
    var status: Bool
    var date: String
    var nextdate: String
    var remainingDays: Int
    var gid: String?
    
    init?(id: String, name: String, image: UIImage, plan: String, price: Int, genre: String, status: Bool, date: String, nextdate: String, remainingDays: Int, gid: String?){
        self.id = id
        self.name = name
        self.plan = plan
        self.image = image
        self.price = price
        self.genre = genre
        self.status = status
        self.date = date
        self.nextdate = nextdate
        self.remainingDays = remainingDays
        self.gid = gid
    }
}

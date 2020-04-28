//
//  TableViewCell.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 28/04/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    //Indvidual upcoming view controller
    @IBOutlet weak var upcomingTimeLabel: UILabel!
    @IBOutlet weak var upcomingCostLabel: UILabel!
    @IBOutlet weak var upcomingImage: UIImageView!
    //Subscription view controller
    @IBOutlet weak var subscriptionPackageLabel: UILabel!
    @IBOutlet weak var subscriptionAmountLabel: UILabel!
    //View Subscription view controller
    @IBOutlet weak var viewSubscriptionPackageLabel: UILabel!
    @IBOutlet weak var viewSubscriptionAmountLabel: UILabel!
    //Group view controller
    @IBOutlet weak var groupNameLabel: UILabel!
    //Add group view controller
    @IBOutlet weak var addMemberLabel: UILabel!
    //Selected group view controller
    @IBOutlet weak var selectedGroupImage: UIImageView!
    @IBOutlet weak var selectedGroupTimeLabel: UILabel!
    @IBOutlet weak var selectedGroupCostLabel: UILabel!
    //Home
    @IBOutlet weak var homeIndvidualCostLabel: UILabel!
    @IBOutlet weak var homeIndvidualRemainingLabel: UILabel!
    @IBOutlet weak var homeIndvidualImage: UIImageView!
    @IBOutlet weak var homeGroupCostLabel: UILabel!
    @IBOutlet weak var homeGroupRemainingLabel: UILabel!
    @IBOutlet weak var homeGroupImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

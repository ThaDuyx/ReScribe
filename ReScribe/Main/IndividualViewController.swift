//
//  SecondViewController.swift
//  ReScribe
//
//  Created by Simon Andersen on 09/03/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

let arrayOfSome = ["Viaplay", "Netflix"]

class IndividualViewController: UIViewController {
    @IBOutlet weak var addButtonUI: UIButton!
    @IBOutlet weak var infotabView: UIView!
    @IBOutlet weak var indvidualTableView: UITableView!
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        self.infotabView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: 20)
        self.addButtonUI.round(corners: [.bottomLeft, .bottomRight, .topRight, .topLeft], cornerRadius: 20)
        
    }

}

extension IndividualViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = indvidualTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IndvidualTableViewCell
        cell.costLabel.text = nameArr[indexPath.row]
        return cell
    }
}

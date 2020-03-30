//
//  SubscriptionAddViewController.swift
//  ReScribe
//
//  Created by Christoffer Detlef on 23/03/2020.
//  Copyright © 2020 Simon Andersen. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class SubscriptionAddViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var searchBarUI: UISearchBar!
    
    let subsNameArr = ["Viaplay", "Netflix", "HBO", "Youtube", "CBS", "Twitch", "Cmore", "D-play", "Spotify", "Apple Music", "World of Warcraft", "Apple TV", "Discord", "Strava", "Disney+", "Amazon Prime"]
    
    var searchName = [String]()
    var searching = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBarUI.round(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], cornerRadius: 10)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(netHex: 0x353535)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension SubscriptionAddViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchName.count
        } else {
            return subsNameArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if searching {
            cell?.textLabel?.text = searchName[indexPath.row]
        } else {
            cell?.textLabel?.text = subsNameArr[indexPath.row]
        }
        return cell!
    }
}

extension SubscriptionAddViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchName = subsNameArr.filter({$0.prefix(searchText.count) == searchText})
        searching = true
        tblView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tblView.reloadData()
    }
}
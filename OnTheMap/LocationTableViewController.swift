//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import SafariServices
import UIKit

class LocationTableViewController: UIViewController, UITableViewDelegate {
    
    private let dataSource = LocationDataSource.shared
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource

    }

    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = dataSource.studentLocations[indexPath.row]
        
        guard let url = studentLocation.url else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: url)
        self.present(safariViewController, animated: true, completion: nil)
    }

}

//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by André Brinkop on 04.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

class LocationTableViewController: LocationViewController, UITableViewDelegate {
    
    // MARK: Properties
    private let refreshControl = UIRefreshControl()
    @IBOutlet var tableView: UITableView!
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = locationDataSource
        
        refreshControl.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = locationDataSource.studentLocations[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let url = studentLocation.url else {
            displayErrorMessage(message: "\(studentLocation.firstName) \(studentLocation.lastName) did not provide a (valid) URL!")
            return
        }
        
        openUrl(url: url)
    }
    
    // MARK: Data Source Update
    
    override func didUpdateDataSource() {
        super.didUpdateDataSource()
        tableView.reloadData()
    }
    
    // MARK: Loading Spinner
    
    func handleRefresh() {
        locationDataSource.updateData()
    }
    
    override func showLoadingSpinner() {
        // Move table view to make space for the refresh control (is needed if called from code)
        tableView.setContentOffset(CGPoint(x: 0,y: tableView.contentOffset.y - refreshControl.frame.height), animated: true)
        refreshControl.beginRefreshing()
    }
    
    override func hideLoadingSpinner() {
        refreshControl.endRefreshing()
    }
    
}

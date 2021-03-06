//
//  InfoHistViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class InfoHistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortByDateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Methods
    
    // Customizing the font for a UITabBarItem. A larger font than the default
    // is selected, foreground color is red when selected, and black when normal.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attrsNormal = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0)
        ]
        let attrsSelected = [
            NSAttributedString.Key.foregroundColor: UIColor.red,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0)
        ]
        UITabBarItem.appearance().setTitleTextAttributes(attrsNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attrsSelected, for: .selected)
        
        filterSegmentedControl.ensureiOS12Style()
        sortByDateSegmentedControl.ensureiOS12Style()

    }
    
    // Fetch information from database based on selected criteria and sort
    // options:
    // - pending (not read yet) or all information is fetched from database based
    //   on selected option on first segmented control (Pending or All)
    // - fetched rows are sorted by entry date descending or ascending based on
    //   selected option on second segmented control
    //   (Entry date ↓ or Entry date ↑)
    // After fetching, results are saved in Model's array information for
    // displaying in table view.
    func fetchFilteredInfo() {
        
        var done: Bool?
        var orderByDateAsc: Bool?
        
        if filterSegmentedControl.selectedSegmentIndex == 0 { // Pending
            done = false
        } else { // All
            done = nil
        }
        
        if sortByDateSegmentedControl.selectedSegmentIndex == 0 { // Date Desc
            orderByDateAsc = false
        } else { // Date Asc
            orderByDateAsc = true
        }
        
        if let results = CoreDataManager.sharedInstance.fetchInfo(forDate: nil, andDone: done,  orderByDateAcs: orderByDateAsc) {
            Model.sharedInstance.information = results
            //print(results)
        }
    }

    // When whatever segmented control value is changed then fetch information
    // from database based on selected criteria and sort options as described
    // above. After fetching, results are saved in Model's array information for
    // displaying in table view. Then reload new fetched information in table
    // view.
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        fetchFilteredInfo()
        tableView.reloadData()
    }
    
    // Whenever main view is displayed then do as in the case when segmented
    // control value is changed: fetch information from database based on selected
    // criteria and sort options as described above. After fetching, results are
    // saved in Model's array information for displaying in table view. Then
    // reload new fetched information in table view. After this, set tab bar
    // controller title to "Information".
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFilteredInfo()
        tableView.reloadData()
        self.tabBarController?.title = "Information"
    }
    
    // MARK: - tableView for information - methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.sharedInstance.information.count
    }
    
    // In tableview there are three information related fields: entry date,
    // information and read flag. Entry date is displayed in short format
    // without time componnent. All data is read from Model's array information.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCellIdentifier", for: indexPath) as! InfoTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: Model.sharedInstance.information[indexPath.row].entryDate! as Date)
        
        cell.dateLabel.text = dateString
        
        cell.informationLabel.text = Model.sharedInstance.information[indexPath.row].information
        
        cell.readSwitch.isOn = Model.sharedInstance.information[indexPath.row].done
        
        return cell
        
    }
    
    // MARK: - Delete - methods
    
    // Enable editing table view row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Enable deleting table view row - when delete is selected information is removed from three places:
    // from Model's information array, from table view and then from database.
    // End user must confirm deleting.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            askUser(
                controller: self,
                title: "Deleting information",
                message: "Do you really want to delete this information? Tap Delete to continue or Cancel to cancel this action.",
                okTitle: "Delete",
                cancelTitle: "Cancel",
                okActionStyle: UIAlertAction.Style.destructive,
                cancelActionStyle: UIAlertAction.Style.cancel,
                okAction: { (action) in
                    let info = Model.sharedInstance.information[indexPath.row]
                    Model.sharedInstance.information.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    CoreDataManager.sharedInstance.deleteEntity(info)
            },
                cancelAction: { (action) in
                    return
            })
        }
    }
    
    // MARK: - Navigation
    
    // If navigation to other screen is caused by selecting row in tableview, then
    // before navigation, Model's currentInformation variable is set to information selected in tableview.
    // Otherwise, Model's currentInformation variable is set to nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            Model.sharedInstance.currentInformation = Model.sharedInstance.information[(indexPath?.row)!]
        }
        else {
            Model.sharedInstance.currentInformation = nil
        }
    }
    
    // When information in tableview is selected, navigate to InfoViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueInfoHistToInfo", sender: nil)
    }
    
}

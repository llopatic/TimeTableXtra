//
//  TimetablePlusViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 12/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class TimetablePlusViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoButton: UIBarButtonItem!
    
    // MARK: - Methods viewDidLoad, viewWillAppear, pickerView - didSelectRow, segmentedIndexDidChange
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set height of table view row
        tableView.rowHeight = 40
        
        // Populate segmented control segment titles with two types of timetables this application supports
        segmentedControl.setTitle(CoreDataManager.sharedInstance.fetchTimetableName(seqNo: 0), forSegmentAt: 0)
        segmentedControl.setTitle(CoreDataManager.sharedInstance.fetchTimetableName(seqNo: 1), forSegmentAt: 1)
        
        // Set Model's variables currentTimetable and currentDay with selected values on the screen
        Model.sharedInstance.currentTimetable = Model.sharedInstance.timetables[segmentedControl.selectedSegmentIndex]
        Model.sharedInstance.currentDay = Model.sharedInstance.days[pickerView.selectedRow(inComponent: 0)]
        
    }
    
    
    // Before the screen appears fetch from database data for Model's arrays subjects and items.
    // Fetched items are timetable items beloging to the current timetable and day as defined in
    // Model by corresponding variables: currentTimetable and currentDay.
    // Then refresh table view with refreshed Model's array items.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let results = CoreDataManager.sharedInstance.fetchSubjects() {
            Model.sharedInstance.subjects = results
            //print(results)
        }
        
        if let results = CoreDataManager.sharedInstance.fetchItems() {
            Model.sharedInstance.items = results
            //print(results)
        }
        
        tableView.reloadData()
        
    }
    
    // When the new day in picker is selected, this day becomes current day in Model, and then for this new current day
    // and existing current timetable, timetable items are fetched from database and put into the Model's array items.
    // After that table view is refreshed with new data in Model's array items.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Model.sharedInstance.currentDay = Model.sharedInstance.days[pickerView.selectedRow(inComponent: 0)]
        if let results = CoreDataManager.sharedInstance.fetchItems() {
            Model.sharedInstance.items = results
            //print(results)
        }
        tableView.reloadData()
    }
    
    // When the new timetable in segmented control is selected, this timetable becomes current timetable in Model,
    // and then for this new current timetable and existing current day, timetable items are fetched from database
    // and put into the Model's array items.
    // After that table view is refreshed with new data in Model's array items.
    @IBAction func segmentedIndexDidChange() {
        Model.sharedInstance.currentTimetable = Model.sharedInstance.timetables[segmentedControl.selectedSegmentIndex]
        if let results = CoreDataManager.sharedInstance.fetchItems() {
            Model.sharedInstance.items = results
            //print(results)
        }
        tableView.reloadData()
    }
    
    // MARK: - pickerView for days - methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Model.sharedInstance.days.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Model.sharedInstance.days[row].name
    }
    
    // MARK: - tableView for timetable items - methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.sharedInstance.items.count
    }
    
    // If there is at least one homework not done yet for current subject then left cell's
    // label background color is set to orange color - otherwise the background color is green.
    // If there is at least one exam not done yet for current subject then right cell's
    // label background color is set to red color - otherwise the color is green.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCellIdentifier", for: indexPath) as! ItemTableViewCell
        
        cell.fromLabel.text = Model.sharedInstance.items[indexPath.row].from!
        cell.toLabel.text = Model.sharedInstance.items[indexPath.row].to!
        cell.subjectLabel.text = Model.sharedInstance.items[indexPath.row].relSubject?.name!

        let customGreen = UIColor(red: 140.0/255.0, green: 255.0/255.0, blue: 56.0/255.0, alpha: 1)
        let customRed = UIColor(red: 255.0/255.0, green: 61.0/255.0, blue: 48.0/255.0, alpha: 1)
        let customOrange = UIColor(red: 255.0/255.0, green: 165.0/255.0, blue: 0.0/255.0, alpha: 1)
        
        if CoreDataManager.sharedInstance.existsPendingHomework(
            forSubject: Model.sharedInstance.items[indexPath.row].relSubject!)
        {
            cell.leftLabel.backgroundColor = customOrange
        } else {
            cell.leftLabel.backgroundColor = customGreen
        }
        
        if CoreDataManager.sharedInstance.existsPendingExam(
            forSubject: Model.sharedInstance.items[indexPath.row].relSubject!)
        {
            cell.rightLabel.backgroundColor = customRed
        } else {
           cell.rightLabel.backgroundColor = customGreen
        }
        
        return cell
    
    }
    
    // MARK: - Delete - methods
    
    // Enable editing table view row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Enable deleting table view row - when delete is selected timetable item is removed from three places:
    // from Model's items array, from table view and then from database.
    // End user must confirm deleting.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            askUser(
                controller: self,
                title: "Deleting timetable item",
                message: "Do you really want to delete this timetable item? Tap Delete to continue or Cancel to cancel this action.",
                okTitle: "Delete",
                cancelTitle: "Cancel",
                okActionStyle: UIAlertActionStyle.destructive,
                cancelActionStyle: UIAlertActionStyle.cancel,
                okAction: { (action) in
                    let item = Model.sharedInstance.items[indexPath.row]
                    Model.sharedInstance.items.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    CoreDataManager.sharedInstance.deleteEntity(item)
            },
                cancelAction: { (action) in
                    return
            })
        }
    }
    
    // MARK: - Entering homework or exam when selected item in tableview - possible options in alert
    
    // Options in alert are:
    // New homework - to enter new homework
    // Last homework - to update existing homework of latest entry date
    // New exam - to enter new exam
    // Last exam - to update existing exam of latest exam date
    // Update timetable item - to update timetable item
    // Options Last homework or Last exam are not displayed if there is no homework or exam yet
    // for current subject
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var actions = [
                [
                    "actionTitle":"New homework",
                    "actionStyle":UIAlertActionStyle.default,
                    "actionHandler":
                        {
                            (action: UIAlertAction) -> (Void) in
                            Model.sharedInstance.lastHomework = nil
                            self.performSegue(withIdentifier: "segueTimetableToHomework", sender: self)
                        } as Any
                ]
        ]
        
        if let lastHomework = CoreDataManager.sharedInstance.fetchLastHomework(forSubject: Model.sharedInstance.items[indexPath.row].relSubject!) {
            Model.sharedInstance.lastHomework = lastHomework
            actions.append(
                [
                    "actionTitle":"Last homework",
                    "actionStyle":UIAlertActionStyle.default,
                    "actionHandler":
                        {
                            (action: UIAlertAction) -> (Void) in
                            self.performSegue(withIdentifier: "segueTimetableToHomework", sender: self)
                        } as Any
                ])
        } else {
            Model.sharedInstance.lastHomework = nil
        }
        
        actions.append(
            [
                "actionTitle":"New exam",
                "actionStyle":UIAlertActionStyle.default,
                "actionHandler":
                    {
                        (action: UIAlertAction) -> (Void) in
                        Model.sharedInstance.lastExam = nil
                        self.performSegue(withIdentifier: "segueTimetableToExam", sender: self)
                    } as Any
            ])
        
        if let lastExam = CoreDataManager.sharedInstance.fetchLastExam(forSubject: Model.sharedInstance.items[indexPath.row].relSubject!) {
            Model.sharedInstance.lastExam = lastExam
            actions.append(
                [
                    "actionTitle":"Last exam",
                    "actionStyle":UIAlertActionStyle.default,
                    "actionHandler":
                        {
                            (action: UIAlertAction) -> (Void) in
                            self.performSegue(withIdentifier: "segueTimetableToExam", sender: self)
                        } as Any
                ])
        } else {
            Model.sharedInstance.lastExam = nil
        }
       
        actions.append(
            [
                "actionTitle":"Update timetable item",
                "actionStyle":UIAlertActionStyle.default,
                "actionHandler":
                    {
                        (action: UIAlertAction) -> (Void) in
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "segueTimetableToItem", sender: self)
                        }
        
                    } as Any
            ])
        
        actions.append(
            [
                "actionTitle":"Cancel",
                "actionStyle":UIAlertActionStyle.cancel,
                "actionHandler":
                    {
                        (action: UIAlertAction) -> (Void) in
                        tableView.deselectRow(at: indexPath, animated: false)
                    } as Any
            ])
        
        askUserForOption(
            controller: self,
            title: "Options",
            message: "Please, select an option",
            actions: actions
        )

    }
    
    
    // MARK: - Navigation
    
    // If navigation to other screen is caused by selecting row in tableview, then
    // before navigation Model's currentItem variable is set to item selected in tableview.
    // Otherwise, i.e. if navigation is caused by pressing '+' button then Model's
    // currentItem variable is set to nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            Model.sharedInstance.currentItem = Model.sharedInstance.items[(indexPath?.row)!]
        }
        else {
            Model.sharedInstance.currentItem = nil
        }
    }
    
    // Ensuring that navigation to screen Item (TimeTableItemViewController)
    // is not possible if there is no subject saved in database
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "segueTimetableToItem" && Model.sharedInstance.subjects.count == 0 {
            let alert = UIAlertController(
                    title: "Warning!",
                    message: "Before inserting timetable items, please define at least one Subject in Settings!",
                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true) {}
            return false
        } else {
            return true
        }
    }
   
    // MARK: - Entering information when Info button is pressed - possible options in alert
    
    // Options in alert are:
    // New information - to enter new information
    // Last information - to update existing information of latest entry date
    // Option Last information is not displayed if there is no information yet
    @IBAction func InfoButtonClicked() {
        var actions = [
            [
                "actionTitle":"New Information",
                "actionStyle":UIAlertActionStyle.default,
                "actionHandler":
                    {
                        (action: UIAlertAction) -> (Void) in
                        Model.sharedInstance.lastInformation = nil
                        self.performSegue(withIdentifier: "segueTimetableToInfo", sender: self)
                        } as Any
            ]
        ]
        
        if let lastInformation = CoreDataManager.sharedInstance.fetchLastInformation() {
            Model.sharedInstance.lastInformation = lastInformation
            actions.append(
                [
                    "actionTitle":"Last information",
                    "actionStyle":UIAlertActionStyle.default,
                    "actionHandler":
                        {
                            (action: UIAlertAction) -> (Void) in
                            self.performSegue(withIdentifier: "segueTimetableToInfo", sender: self)
                            } as Any
                ])
        } else {
            Model.sharedInstance.lastInformation = nil
        }
    
        actions.append(
            [
                "actionTitle":"Cancel",
                "actionStyle":UIAlertActionStyle.cancel,
                "actionHandler":
                    {
                        (action: UIAlertAction) -> (Void) in
                        return
                        } as Any
            ])
        
        askUserForOption(
            controller: self,
            title: "Options",
            message: "Please, select an option",
            actions: actions
        )
        
    }
    
}

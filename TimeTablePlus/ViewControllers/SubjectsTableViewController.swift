//
//  SubjectsTableViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 12/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class SubjectsTableViewController: UITableViewController {

    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    // Before view will be displayed fetch subjects from database, populate
    // subjects array in Model with fetched subjects and reload data in
    // tableview from this array
    override func viewWillAppear(_ animated: Bool) {
        if let results = CoreDataManager.sharedInstance.fetchSubjects() {
            Model.sharedInstance.subjects = results
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Model.sharedInstance.subjects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCellIdentifier", for: indexPath)
        
        let font = UIFont(name: "System", size: 17.0)
        cell.textLabel?.font = font
        cell.textLabel?.textAlignment = .center
        let text = Model.sharedInstance.subjects[indexPath.row].name
        cell.textLabel?.text = text
        
        return cell
    }

    // MARK: - Delete - methods
    
    // Enable editing table view row
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Enable deleting table view row - when delete is selected subject
    // is removed from three places: from Model's subjects array, from table
    // view and then from database. But deleting is possible only if the
    // current subject to be deleted has no related timetable items, homeworks
    // or exams or if it has them but the end user allows cascade deleting of
    // related timetable items, homeworks and exams
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if CoreDataManager.sharedInstance.existsTimetableItemFor(subject: Model.sharedInstance.subjects[indexPath.row]) {
                askUser(
                    controller: self,
                    title: "Deleting subject",
                    message: "This subject has related timetable items. If you delete it, all related timetable items will be deleted too. If the subject has related homework assignments and exams they will be deleted as well. Tap Delete to continue or Cancel to cancel this action.",
                    okTitle: "Delete",
                    cancelTitle: "Cancel",
                    okActionStyle: UIAlertActionStyle.destructive,
                    cancelActionStyle: UIAlertActionStyle.cancel,
                    okAction: { (action) in
                        let subject = Model.sharedInstance.subjects[indexPath.row]
                        Model.sharedInstance.subjects.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .left)
                        CoreDataManager.sharedInstance.deleteEntity(subject)
                    },
                    cancelAction: { (action) in
                        return
                    })
            } else if CoreDataManager.sharedInstance.existsHomeworkFor(subject: Model.sharedInstance.subjects[indexPath.row])  {
                askUser(
                    controller: self,
                    title: "Deleting subject",
                    message: "This subject has related homework assignments. If you delete it, all related homework assignments will be deleted too. If the subject has related exams they will be deleted as well. Tap Delete to continue or Cancel to cancel this action.",
                    okTitle: "Delete",
                    cancelTitle: "Cancel",
                    okActionStyle: UIAlertActionStyle.destructive,
                    cancelActionStyle: UIAlertActionStyle.cancel,
                    okAction: { (action) in
                        let subject = Model.sharedInstance.subjects[indexPath.row]
                        Model.sharedInstance.subjects.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .left)
                        CoreDataManager.sharedInstance.deleteEntity(subject)
                },
                    cancelAction: { (action) in
                        return
                })
            } else if CoreDataManager.sharedInstance.existsExamFor(subject: Model.sharedInstance.subjects[indexPath.row]){
                askUser(
                    controller: self,
                    title: "Deleting subject",
                    message: "This subject has related exams. If you delete it, all related exams will be deleted too. Tap Delete to continue or Cancel to cancel this action.",
                    okTitle: "Delete",
                    cancelTitle: "Cancel",
                    okActionStyle: UIAlertActionStyle.destructive,
                    cancelActionStyle: UIAlertActionStyle.cancel,
                    okAction: { (action) in
                        let subject = Model.sharedInstance.subjects[indexPath.row]
                        Model.sharedInstance.subjects.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .left)
                        CoreDataManager.sharedInstance.deleteEntity(subject)
                },
                    cancelAction: { (action) in
                        return
                })
            }
            else {
                askUser(
                    controller: self,
                    title: "Deleting subject",
                    message: "Do you really want to delete this subject? Tap Delete to continue or Cancel to cancel this action.",
                    okTitle: "Delete",
                    cancelTitle: "Cancel",
                    okActionStyle: UIAlertActionStyle.destructive,
                    cancelActionStyle: UIAlertActionStyle.cancel,
                    okAction: { (action) in
                        let subject = Model.sharedInstance.subjects[indexPath.row]
                        Model.sharedInstance.subjects.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .left)
                        CoreDataManager.sharedInstance.deleteEntity(subject)
                },
                    cancelAction: { (action) in
                        return
                })
            }
        }
    }
    
    // MARK: -  Go to view for updating selected subject in tableview
    
    // Selecting row in tableview causes navigation to SubjectViewController
    // where name of the subject can be changed.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueSubjectsToSubject", sender: nil)
    }
    
    // MARK: - Navigation
    
    // If navigation to other screen is caused by selecting row in tableview, then
    // before navigation Model's currentSubject variable is set to subject selected
    // in tableview. Otherwise, i.e. if navigation is caused by pressing '+' button
    // then Model's currentSubject variable is set to nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            Model.sharedInstance.currentSubject = Model.sharedInstance.subjects[(indexPath?.row)!]
        }
        else {
            Model.sharedInstance.currentSubject = nil
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

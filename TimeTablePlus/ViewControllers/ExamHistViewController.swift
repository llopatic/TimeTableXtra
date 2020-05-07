//
//  ExamHistViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class ExamHistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var firstSortBySegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortByDateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortBySubjectSegmentedControl: UISegmentedControl!
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
        firstSortBySegmentedControl.ensureiOS12Style()
        sortByDateSegmentedControl.ensureiOS12Style()
        sortBySubjectSegmentedControl.ensureiOS12Style()

    }
    
    // Fetch exams from database based on selected criteria and sort options:
    // - pending (not done yet) or all exams are fetched from database based
    //   on selected option on first segmented control (Pending or All)
    // - fetched rows are sorted first by date and then by subject or first by
    //   subject and then by date based on selected option on second segmented
    //   control (First sort by date or First sort by subject)
    // - fetched rows are sorted by exam date descending or ascending based on
    //   selected option on third segmented control (Exam date ↓ or Exam date ↑)
    // - fetched rows are sorted by subject ascending or descending based on
    //   selected option on fourth segmented control (Subject ↑ or Subject ↓)
    // After fetching, results are saved in Model's array exams for displaying
    // in table view.
    func fetchFilteredExams() {
        
        var done: Bool?
        var firstOrderByDate: Bool?
        var orderByDateAsc: Bool?
        var orderBySubjectAsc: Bool?
        
        
        if filterSegmentedControl.selectedSegmentIndex == 0 { // Pending
            done = false
        } else { // All
            done = nil
        }
        
        if firstSortBySegmentedControl.selectedSegmentIndex == 0 { // Date
            firstOrderByDate = true
        } else { // Subject
            firstOrderByDate = false
        }
        
        if sortByDateSegmentedControl.selectedSegmentIndex == 0 { // Date Desc
            orderByDateAsc = false
        } else { // Date Asc
            orderByDateAsc = true
        }
        
        if sortBySubjectSegmentedControl.selectedSegmentIndex == 0 { // Subject Asc
            orderBySubjectAsc = true
        } else { // Subject Desc
            orderBySubjectAsc = false
        }
        
        if let results = CoreDataManager.sharedInstance.fetchExams(forDate: nil, andSubject: nil, andDone: done, orderByDateAcs: orderByDateAsc, orderBySubjectAsc: orderBySubjectAsc, firstOrderByDate: firstOrderByDate) {
            Model.sharedInstance.exams = results
            //print(results)
        }
        
    }
    
    // When whatever segmented control value is changed then fetch exams
    // from database based on selected criteria and sort options as described
    // above. After fetching, results are saved in Model's array exams for
    // displaying in table view. Then reload new fetched exams in table view.
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        fetchFilteredExams()
        tableView.reloadData()
    }
    
    // Whenever main view is displayed then do as in the case when segmented
    // control value is changed: fetch exams from database based on selected
    // criteria and sort options as described above. After fetching, results are
    // saved in Model's array exams for displaying in table view. Then reload
    // new fetched exams in table view. After this, set tab bar controller
    // title to "Exams".
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFilteredExams()
        tableView.reloadData()
        self.tabBarController?.title = "Exams"
    }
    
    // MARK: - tableView for exams - methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.sharedInstance.exams.count
    }
    
    // In tableview there are three exam related fields: exam date, subject
    // and done flag. Exam date is displayed in short format without time
    // componnent. All data is read from Model's array exams.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamsTableViewCellIdentifier", for: indexPath) as! ExamsTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: Model.sharedInstance.exams[indexPath.row].examDate! as Date)
        
        cell.dateLabel.text = dateString
        
        cell.subjectLabel.text = Model.sharedInstance.exams[indexPath.row].relSubject?.name
        
        cell.doneSwitch.isOn = Model.sharedInstance.exams[indexPath.row].done
        
        return cell
        
    }
    
    // MARK: - Delete - methods
    
    // Enable editing table view row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Enable deleting table view row - when delete is selected exam is removed from three places:
    // from Model's exams array, from table view and then from database.
    // End user must confirm deleting.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            askUser(
                controller: self,
                title: "Deleting exam",
                message: "Do you really want to delete this exam? Tap Delete to continue or Cancel to cancel this action.",
                okTitle: "Delete",
                cancelTitle: "Cancel",
                okActionStyle: UIAlertAction.Style.destructive,
                cancelActionStyle: UIAlertAction.Style.cancel,
                okAction: { (action) in
                    let exam = Model.sharedInstance.exams[indexPath.row]
                    Model.sharedInstance.exams.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    CoreDataManager.sharedInstance.deleteEntity(exam)
            },
                cancelAction: { (action) in
                    return
            })
        }
    }
    
    // MARK: - Navigation
    
    // If navigation to other screen is caused by selecting row in tableview, then
    // before navigation, Model's currentExam variable is set to exam selected in tableview.
    // Otherwise, Model's currentExam variable is set to nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath != nil {
            Model.sharedInstance.currentExam = Model.sharedInstance.exams[(indexPath?.row)!]
        }
        else {
            Model.sharedInstance.currentExam = nil
        }
    }
    
    // When exam in tableview is selected, navigate to ExamViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueExamHistToExam", sender: nil)
    }
    
}

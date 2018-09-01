//
//  TimeTableItemViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 12/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class TimeTableItemViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var pickerView1: UIPickerView!
    @IBOutlet weak var pickerView2: UIPickerView!
    @IBOutlet weak var pickerView3: UIPickerView!
    @IBOutlet weak var timetableLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    // MARK: - Variables accessible at instance level
    
    var interval: Int!
    
    // MARK: - Method viewDidLoad, initial calculating from date, to date and subject in picker views
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Define interval in time picker
        interval = Model.sharedInstance.interval

        // Display current timetable and day as defined in Model
        timetableLabel.text = Model.sharedInstance.currentTimetable?.name
        dayLabel.text = Model.sharedInstance.currentDay?.name
    
        // Declare local variables needed
        // The time in component 0 of pickerView1 and pickerView2 is expressed in minutes
        // after midnight. One row in these pickers represents number of minutes defined in
        // interval setting (for example 5 minutes). Row 0 means 0 minutes, row 1 means
        // 1xinterval minutes, row 2 means 2*interval minutes ... (for example 0,5,10, ...
        // minutes). Component 1 of these pickers represents am/pm indicator: am or pm.
        // In entity Item there are the following time attributes: from, to, intFrom, intTo.
        // From and to are strings which has am/pm time format like: "8:00 am".
        // intFrom and intTo are integers which contain minutes after midnight - for 8:00 am
        // number of minutes after midnight = 8*60 = 480, for 8:00 pm number of minutes after
        // midnight = (8+12)*60 = 20*60 = 1200.
        
        var initialFromRow: Int?
        var initialFromAmPmRow: Int?
        var initialToRow: Int?
        var initialToAmPmRow: Int?

        // Calculate time for next item based on values defined in Settings.
        // By default morning timetable starts at 8:00 am and afternoon timetable starts at 1:30 pm
        // These two values cannot be set in settings.
        func calculateTimeForNextItem() {
            if Model.sharedInstance.items.count == 0 {
                // If creating first item for current timetable and day:
                if Model.sharedInstance.currentTimetable?.name == "Afternoon" {
                    // Afternoon timetable begins at 1:30 pm
                    // initialFromRow defines row in pickerView1 in component 0 for time 1:30 pm
                    // initialFromAmPmRow defines row in pickerView1 in component 1 for indicator am/pm of time 1:30 pm
                    // initialToRow defines row in pickerView2 in component 0 for time 1:30 pm + classPeriodDuration setting
                    // initialToAmPmRow defines row in pickerView2 in component 1 for indicator am/pm of time 1:30 pm + classPeriodDuration setting
                    initialFromRow = (13*60+30)/interval
                    initialFromAmPmRow = Model.sharedInstance.amPm(totalMinutes: initialFromRow! * interval)
                    initialToRow = (13*60+30+Model.sharedInstance.classPeriodDuration)/interval
                    initialToAmPmRow = Model.sharedInstance.amPm(totalMinutes: initialToRow! * interval)
                } else {
                    // Morning timetable begins at 8:00 am
                    // initialFromRow defines row in pickerView1 in component 0 for time 8:00 am
                    // initialFromAmPmRow defines row in pickerView1 in component 1 for indicator am/pm of time 8:00 am
                    // initialToRow defines row in pickerView2 in component 0 for time 8:00 am + classPeriodDuration setting
                    // initialToAmPmRow defines row in pickerView2 in component 1 for indicator am/pm of time 8:00 am + classPeriodDuration setting
                    initialFromRow = (8*60)/interval
                    initialFromAmPmRow = Model.sharedInstance.amPm(totalMinutes: initialFromRow! * interval)
                    initialToRow = (8*60+Model.sharedInstance.classPeriodDuration)/interval
                    initialToAmPmRow = Model.sharedInstance.amPm(totalMinutes: initialToRow! * interval)
                }
            } else {
                // If not creating first item for current timetable and day:
                // To create next item, firstly item of max from time is found.
                // Then pauseDuration setting is added to to time of item found in previous step.
                // Calculated time is from time of next item.
                // To time of next item is from time of it plus classPeriodDuration setting.
                // For calculated from and to times of next item corresponding rows in pickerView1 and pickerView2 are calculated.
                // am/pm indicators are calculated for both from and to times of the new item
                // Max calculated from and to times are 11:55 pm (1435 minutes after midnight)
                let maxItem = Model.sharedInstance.items.sorted(by: { $0.intFrom > $1.intFrom })[0]
                var intFrom = Int(maxItem.intTo) + Model.sharedInstance.pauseDuration
                if intFrom > 1435 {
                    intFrom = 1435
                }
                var intTo = Int(intFrom) + Model.sharedInstance.classPeriodDuration
                if intTo > 1435 {
                    intTo = 1435
                }
                let amPmFrom = Model.sharedInstance.amPm(totalMinutes: intFrom)
                let amPmTo = Model.sharedInstance.amPm(totalMinutes: intTo)
                initialFromRow = intFrom/interval
                initialFromAmPmRow = amPmFrom
                initialToRow = intTo/interval
                initialToAmPmRow = amPmTo
            }
        }
        
        if let item = Model.sharedInstance.currentItem {
            //Item is selected in tableview in TimetablePlusViewController, i.e. existing item is updated.
            // This way, from and to times of the item are known meaning that rows in
            // corresponding picker views can be calculated.
            
            pickerView1.selectRow(Int(item.intFrom)/interval, inComponent: 0, animated: false)
            pickerView1.selectRow(Model.sharedInstance.amPm(totalMinutes: Int(item.intFrom)), inComponent: 1, animated: false)
            pickerView2.selectRow(Int(item.intTo)/interval, inComponent: 0, animated: false)
            pickerView2.selectRow(Model.sharedInstance.amPm(totalMinutes: Int(item.intTo)), inComponent: 1, animated: false)
            
            pickerView3.selectRow(Model.sharedInstance.subjects.index(of: item.relSubject!)!, inComponent: 0, animated: false)
        }
        else {
            // Plus is clicked in TimetablePlusViewController, i.e. new timetable item is created
            // Firstly, calculate from and to times for the new item, and then display
            // them in corresponding picker views.
            calculateTimeForNextItem()
            pickerView1.selectRow(initialFromRow!, inComponent: 0, animated: true)
            pickerView1.selectRow(initialFromAmPmRow!, inComponent: 1, animated: true)
            pickerView2.selectRow(initialToRow!, inComponent: 0, animated: true)
            pickerView2.selectRow(initialToAmPmRow!, inComponent: 1, animated: true)
        }
        
        // Fetch subjects from database and save them to Model's array subjects
        if let results = CoreDataManager.sharedInstance.fetchSubjects() {
            Model.sharedInstance.subjects = results
        }
        
        // Define current subject in Model as the selected subject in pickerView3.
        // If pickerView3 is now referenced for the first time (i.e. new item is created)
        // it is firstly populated with subjects fetched in previous statement.
        Model.sharedInstance.currentSubject = Model.sharedInstance.subjects[pickerView3.selectedRow(inComponent: 0)]
     
    }
    
    // MARK: - Picker views methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == pickerView1 || pickerView == pickerView2 {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
            if pickerView == pickerView1 || pickerView == pickerView2 {
                switch component {
                    case 0: return 24*60/interval
                    case 1: return 2
                    default: return 0
                }
            } else {
                return Model.sharedInstance.subjects.count
            }
        }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerView1 || pickerView == pickerView2 {
            switch component {
            case 0: return hoursMinutes(minutes: row*interval)
            case 1:
                if row == 0 {
                    return "am"
                } else {
                    return "pm"
                }
            default: return ""
            }
        } else {
            return Model.sharedInstance.subjects[row].name
        }
    }
    
    // This method converts minutes from midnight to hours and minutes where
    // hours are prepared for am/pm time format
    func hoursMinutes(minutes: Int) -> String {
        var intHours = minutes/60
        if intHours == 0 {
            intHours = 12
        } else if intHours >= 13 {
            intHours -= 12
        }
        let intMinutes = minutes % 60
        let strHours = String(format: "%02d", intHours)
        let strMinutes = String(format: "%02d", intMinutes)
        return strHours + ":" + strMinutes
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == pickerView1 || pickerView == pickerView2) {
            if component == 0 {
                // After 11:59 am time has indicator pm
                // Before 12:00 pm time has indicator am
                let intHours = row*interval/60
                if intHours < 12 {
                    pickerView.selectRow(0, inComponent: 1, animated: true)
                } else {
                    pickerView.selectRow(1, inComponent: 1, animated: true)
                }
            } else {
                // If am/pm indicator is changed, then the time in component 0 which is expressed
                // in minutes after midnight has to be updated accordingly: if am/pm indicator
                // is changed to am 12*60 minutes is subtracted from time in component 0 and
                // if am/pm indicator is changed to pm 12*60 minutes is added to time in
                // component 0
                let rowInComponent0 = pickerView.selectedRow(inComponent: 0)
                let intHours =  rowInComponent0 * interval/60
                if intHours < 12 && row == 1 {
                    pickerView.selectRow(rowInComponent0+12*60/interval, inComponent: 0, animated: true)
                } else if intHours >= 12 && row == 0 {
                    pickerView.selectRow(rowInComponent0-12*60/interval, inComponent: 0, animated: true)
                }
            }
        } else
        {
            // currentSubject in Model becomes selected subject in pickerView3
            Model.sharedInstance.currentSubject = Model.sharedInstance.subjects[row]
        }
    }
    
    // MARK: - Method saveButtonClicked
    
    // This method returns true if From time is earlier than To time
    // otherwise it reuturns false
    func validateDates(from: String, to: String) -> Bool {
        if CoreDataManager.sharedInstance.totalMinutes(time: from) >= CoreDataManager.sharedInstance.totalMinutes(time: to) {
            return false
        } else {
            return true
        }
    }
    
    // Save timetable item entered or updated. It is not allowed to override already existing item.
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        // Gather timetable components
        let timetable = Model.sharedInstance.currentTimetable
        let day = Model.sharedInstance.currentDay
        let from = pickerView(pickerView1
            , titleForRow: pickerView1.selectedRow(inComponent: 0), forComponent: 0)! + " " + pickerView(pickerView1
                , titleForRow: pickerView1.selectedRow(inComponent: 1), forComponent: 1)!
        let to = pickerView(pickerView2
            , titleForRow: pickerView2.selectedRow(inComponent: 0), forComponent: 0)! + " " + pickerView(pickerView2
                , titleForRow: pickerView2.selectedRow(inComponent: 1), forComponent: 1)!
        let subject = Model.sharedInstance.currentSubject
        // Ensuring that From time is earlier than To time
        if validateDates(from: from, to: to) == false {
            informUser(controller: self, title: "Error validating times", message: "From time must be earlier than To time. Please, correct times before saving timetable item.", okTitle: "OK", okActionStyle: .default, okAction: nil)
            return
        }
        if Model.sharedInstance.currentItem == nil {
            // insert timetable item into database if it does not exist in database yet
            if CoreDataManager.sharedInstance.isUniqueItem(timetable: timetable!, day: day!, from: from, to: to, subject: subject!) {
                CoreDataManager.sharedInstance.saveTimetableItem(timetable: timetable!, day: day!, from: from, to: to, subject: subject!)
                self.navigationController?.popViewController(animated: true)
            } else {
                informUser(controller: self, title: "Error saving data", message: "This timetable item already exists! If you want to change this timetable item, please select it on the Timetable Xtra screen and then select the menu option Update timetable item.", okTitle: "OK", okActionStyle: .default, okAction: nil)
            }
        } else {
            // update current timetable item in database if updated item does not exist in database yet
            if CoreDataManager.sharedInstance.isUniqueItem(timetable: timetable!, day: day!, from: from, to: to, subject: subject!) {
                Model.sharedInstance.currentItem?.from = from
                Model.sharedInstance.currentItem?.intFrom = Int64(CoreDataManager.sharedInstance.totalMinutes(time: from))
                Model.sharedInstance.currentItem?.to = to
                Model.sharedInstance.currentItem?.intTo = Int64(CoreDataManager.sharedInstance.totalMinutes(time: to))
                Model.sharedInstance.currentItem?.relSubject = subject
                CoreDataManager.sharedInstance.saveContext()
                self.navigationController?.popViewController(animated: true)
            } else {
                if let newItem = CoreDataManager.sharedInstance.fetchItem(timetable: timetable!, day: day!, from: from, to: to, subject: subject!) {
                    if newItem != Model.sharedInstance.currentItem {
                        informUser(controller: self, title: "Error saving data", message: "This timetable item already exists! If you want to change this timetable item, please select it on the Timetable Xtra screen and then select the menu option Update timetable item.", okTitle: "OK", okActionStyle: .default, okAction: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

}

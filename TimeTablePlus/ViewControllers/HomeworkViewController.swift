//
//  HomeworkViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 20/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class HomeworkViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var homeworkTextView: UITextView!
    @IBOutlet weak var homeworkDoneSwitch: UISwitch!
    
    // MARK: - Local variables
    
    private var keyboardPresented = false
    private var activeTextView: UITextView?
    private var entryDate: Date?
    private var subject: Subject?
    private var homework: Homework?
    private var formMode: String?
    
    // MARK: - Methods
    
    // Functionality that ensures that swipe back gesture causes keyboard to hide is
    // implemented. This functionality prevents some bugs that can be hit when view is
    // vertically moved when keyboard shows up and swipe back gesture is not
    // completed. This is achived by setting delegate of
    // interactivePopGestureRecognizer to self in viewDidLoad method, implementing
    // UIGestureRecognizerDelegate protocol and implementing  protocol method:
    // gestureRecognizerShouldBegin. When swipe back gesture is done
    // resignFirstResponder is send to the application. This way keyboard is hidden
    // when swipe back gesture starts regardless which view currently has first
    // responder status.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //Swipe back gesture causes keyboard to hide
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // Designing homeworkTextView, its attributes are defined in Model
        homeworkTextView.layer.cornerRadius = Model.sharedInstance.cornerRadius
        homeworkTextView.backgroundColor = Model.sharedInstance.backgroundColor
        homeworkTextView.layer.borderWidth = Model.sharedInstance.borderWidth
        homeworkTextView.layer.borderColor = Model.sharedInstance.borderColor
        
        // Defining method that will be run when keyboard shows up
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HomeworkViewController.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        // Defining method that will be run when keyboard hides
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HomeworkViewController.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)

        // Fetch subjects from database and populate subjects array in Model with fetched subjects
        if let results = CoreDataManager.sharedInstance.fetchSubjects() {
            Model.sharedInstance.subjects = results
        }

        // If navigating from TimetablePlusViewController, currentItem variable in Model is set, and if
        // navigating from HomeworkHistViewController currentHomework variable in Model is set. If
        // navigating from TimetablePlusViewController lastHomework variable can be set or not. If it is
        // set then homework with latest entry date is shown in this view controller and user can change its
        // attributes, otherwise i.e. if lastHomework variable is nil then user creates (inserts) new homework.
        // If navigating from HomeworkHistViewController, user can change currentHomework's attributes.
        // The following attributes are defined for homework: entry date, homework description and done flag.
        // When inserting new homework, entry date is initially set to current date, homework description to
        // placeholder text "Please, enter homework here" and done flag to false.
        // formMode variable is set to Insert if new homework is created and to Update if existing homework
        // is updated.
        if let currentItem = Model.sharedInstance.currentItem {
            //Item is selected in tableview in TimetablePlusViewController
            subject = currentItem.relSubject
            subjectLabel.text = (subject?.name)! + " - homework:"
            if let lastHomework = Model.sharedInstance.lastHomework {
                homework = lastHomework
                entryDate = homework!.entryDate! as Date
                homeworkTextView.text = homework!.hwDesc
                homeworkTextView.textColor = Model.sharedInstance.textColor
                homeworkDoneSwitch.isOn = homework!.done
                formMode = "Update"
            } else {
                homework = nil
                entryDate = truncate(date: Date())
                homeworkTextView.text = "Please, enter homework here"
                homeworkTextView.textColor = Model.sharedInstance.placeHolderColor
                homeworkDoneSwitch.isOn = false
                formMode = "Insert"
            }
        } else if let currentHomework = Model.sharedInstance.currentHomework {
            //Item is selected in tableview in HomeworkHistViewController; Form is in Update Mode
            homework = currentHomework
            subject = homework!.relSubject
            subjectLabel.text = (subject?.name)! + " - homework:"
            entryDate = homework!.entryDate! as Date
            homeworkTextView.text = homework!.hwDesc
            homeworkTextView.textColor = Model.sharedInstance.textColor
            homeworkDoneSwitch.isOn = homework!.done
            formMode = "Update"
        }
        
        datePicker.date = entryDate!
        
    }

    // This method saves homework entered or changed.
    // Homework description must be provided.
    // It is not allowed to override already existing homework.
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        
        var message: String = ""
        
        if validateForm(message: &message) == false  {
            informUser(controller: self, title: "Error validating form", message: message, okTitle: "Ok", okActionStyle: .default, okAction: { (action) in
                
            })
            return
        }
        
        if let homework = CoreDataManager.sharedInstance.fetchHomework(forDate: datePicker.date, andSubject: subject!) {
            if self.homework != homework || self.homework == nil {
                informUser(controller: self, title: "Error saving data", message: "Homework for selected subject and date already exists! If you want to change this homework, please select it on the Homework screen in History.", okTitle: "Ok", okActionStyle: .default, okAction: { (action) in
                    
                })
                return
            }
        }
        
        if formMode == "Update" {
            //homework is not nil
            homework!.entryDate = datePicker.date as NSDate
            homework!.hwDesc = homeworkTextView.text
            homework!.done = homeworkDoneSwitch.isOn
            CoreDataManager.sharedInstance.saveContext()
            self.navigationController?.popViewController(animated: true)        }
        else {
            //insert, formMode == insert, homework is nil
            var maxSeqNo = CoreDataManager.sharedInstance.fetchHomeworkMaxSeqNo()
            if maxSeqNo == nil {
                maxSeqNo = 0
            } else {
                maxSeqNo! +=  1
            }
            CoreDataManager.sharedInstance.saveHomework(seqNo: Int64(maxSeqNo!), entryDate: datePicker.date , subject: subject!, hwDesc: homeworkTextView.text!, done: homeworkDoneSwitch.isOn)
            //print (maxSeqNo!)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // Validatig form i.e. homeworkTextView.
    // This method returns false if homeworkTextView contains only whitespaces i. e.
    // spaces, tabs and carriage returns or if homeworkTextView contains placeholder text.
    // Parametter message is inout parameters - if validation fails, in the message is put
    // text: "Homework not specified" which can then be read in calling method.
    func validateForm(message: inout String) -> Bool {
        
        var formIsValid = true
        
        if homeworkTextView.text.containsOnlyWhitespaces() || homeworkTextView.textColor == Model.sharedInstance.placeHolderColor {
            formIsValid = false
        } else {
            formIsValid = true
        }
        
        if formIsValid {
            message = ""
            return true
        } else {
            message = "Homework not specified!"
            return false
        }
        
    }
    
    // Keyboard notifications methods: keyboardWillShow and keyboardWillHide
    
    // Before keyboard shows up, the main view of this view controller is moved up for deltaY
    // points calculated in AppDelegate based on iphone type. The reason of doing this is to
    // prevent that keyboard covers homeworkTextView.
    @objc func keyboardWillShow(notification: Notification) {
        
            if !keyboardPresented {
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.frame.origin.y -= Model.sharedInstance.deltaY
                })
                
                keyboardPresented = true
            }
        
    }
    
    // Before keyboard hides, the main view of this view controller is moved down for deltaY
    // points defined in AppDelegate based on iphone type.
    @objc func keyboardWillHide(notification: Notification) {
        
            if keyboardPresented {
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.frame.origin.y += Model.sharedInstance.deltaY
                })
                
                keyboardPresented = false
            }
        
    }
    
    // Setting active text view for purpose of hiding keyboard when the user tap
    // outside of keyboard and homeworkTextView.
    // Handling of placeholder text - if in text view is placeholder text i.e. if
    // text color is placeholder color, and user begins editing in text view, then
    // text in text view is set to nil and text color is set to defined text color in Model.
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        if homeworkTextView.textColor == Model.sharedInstance.placeHolderColor {
            homeworkTextView.text = nil
            homeworkTextView.textColor = Model.sharedInstance.textColor
        }
    }
    
    // If at the end of editing text view is empty, then text in text view is set to
    // placeholder text and text color in text view is set to placeholder color.
    func textViewDidEndEditing(_ textView: UITextView) {
        if homeworkTextView.text.isEmpty {
            textView.text = "Please, enter homework here"
            textView.textColor = Model.sharedInstance.placeHolderColor
        }
    }
    
    // When user tap outside of homeworkTextView and keyboard, active text view
    // resigns first responder and keyboard is dismissed
    @IBAction func userDidTap () {
        activeTextView?.resignFirstResponder()
    }
    
}

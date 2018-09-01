//
//  ExamViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 22/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class ExamViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {

    // Na redu je test ovog kontrolera - kod je iskomentiran
    
    // MARK: - Outlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var examTextView: UITextView!
    @IBOutlet weak var examDoneSwitch: UISwitch!
    
    // MARK: - Local variables
    
    private var keyboardPresented = false
    private var activeTextView: UITextView?
    private var examDate: Date?
    private var subject: Subject?
    private var exam: Exam?
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
        
        // Designing examTextView, its attributes are defined in Model
        examTextView.layer.cornerRadius = Model.sharedInstance.cornerRadius
        examTextView.backgroundColor = Model.sharedInstance.backgroundColor
        examTextView.layer.borderWidth = Model.sharedInstance.borderWidth
        examTextView.layer.borderColor = Model.sharedInstance.borderColor
        
        // Defining method that will be run when keyboard shows up
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ExamViewController.keyboardWillShow(notification:)),
            name: Notification.Name.UIKeyboardWillShow,
            object: nil)
        
        // Defining method that will be run when keyboard hides
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ExamViewController.keyboardWillHide(notification:)),
            name: Notification.Name.UIKeyboardWillHide,
            object: nil)
        
        // Fetch subjects from database and populate subjects array in Model with fetched subjects
        if let results = CoreDataManager.sharedInstance.fetchSubjects() {
            Model.sharedInstance.subjects = results
        }
        
        // If navigating from TimetablePlusViewController, currentItem variable in Model is set, and if
        // navigating from ExamHistViewController currentExam variable in Model is set. If
        // navigating from TimetablePlusViewController lastExam variable can be set or not. If it is
        // set then exam with latest exam date is shown in this view controller and user can change its
        // attributes, otherwise i.e. if lastExam variable is nil then user creates (inserts) new exam.
        // If navigating from ExamHistViewController, user can change currentExam's attributes.
        // The following attributes are defined for exam: exam date, exam description and done flag.
        // When inserting new exam, exam date is initially set to current date, exam description to
        // placeholder text "Please, enter exam here" and done flag to false.
        // formMode variable is set to Insert if new exam is created and to Update if existing exam
        // is updated.
        if let currentItem = Model.sharedInstance.currentItem {
            //Item is selected in tableview in TimetablePlusViewController
            subject = currentItem.relSubject
            subjectLabel.text = (subject?.name)! + " - exam:"
            if let lastExam = Model.sharedInstance.lastExam {
                exam = lastExam
                examDate = exam!.examDate! as Date
                examTextView.text = exam!.examDesc
                examTextView.textColor = Model.sharedInstance.textColor
                examDoneSwitch.isOn = exam!.done
                formMode = "Update"
            } else {
                exam = nil
                examDate = truncate(date: Date())
                examTextView.text = "Please, enter exam here"
                examTextView.textColor = Model.sharedInstance.placeHolderColor
                examDoneSwitch.isOn = false
                formMode = "Insert"
            }
        } else if let currentExam = Model.sharedInstance.currentExam {
            //Item is selected in tableview in ExamHistViewController; Form is in Update Mode
            exam = currentExam
            subject = exam!.relSubject
            subjectLabel.text = (subject?.name)! + " - exam:"
            examDate = currentExam.examDate! as Date
            examTextView.text = exam!.examDesc
            examTextView.textColor = Model.sharedInstance.textColor
            examDoneSwitch.isOn = exam!.done
            formMode = "Update"
        }
        
        datePicker.date = examDate!
    }
    
    // This method saves exam entered or changed.
    // Exam description must be provided.
    // It is not allowed to override already existing exam.
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        
        var message: String = ""
        
        if validateForm(message: &message) == false {
            informUser(controller: self, title: "Error validating form", message: message, okTitle: "Ok", okActionStyle: .default, okAction: { (action) in
                
            })
            return
        }
        
        if let exam = CoreDataManager.sharedInstance.fetchExam(forDate: datePicker.date, andSubject: subject!) {
            if self.exam != exam || self.exam == nil {
                informUser(controller: self, title: "Error saving data", message: "Exam for selected subject and date already exists! If you want to change this exam, please select it on the Exams screen in History.", okTitle: "Ok", okActionStyle: .default, okAction: { (action) in
                    
                })
                return
            }
        }
        
        if formMode == "Update" {
            //exam i not nil
            exam!.examDate = datePicker.date as NSDate
            exam!.examDesc = examTextView.text
            exam!.done = examDoneSwitch.isOn
            CoreDataManager.sharedInstance.saveContext()
            self.navigationController?.popViewController(animated: true)        }
        else {
            //insert, formMode == insert, exam is nil
            var maxSeqNo = CoreDataManager.sharedInstance.fetchExamMaxSeqNo()
            if maxSeqNo == nil {
                maxSeqNo = 0
            } else {
                maxSeqNo! +=  1
            }
            CoreDataManager.sharedInstance.saveExam(seqNo: Int64(maxSeqNo!), examDate: datePicker.date, subject: subject!, examDesc: examTextView.text!, done: examDoneSwitch.isOn)
            //print (maxSeqNo!)
            self.navigationController?.popViewController(animated: true)
        }
        
    }

    // Validatig form i.e. examTextView.
    // This method returns false if examTextView contains only whitespaces i. e.
    // spaces, tabs and carriage returns or if examTextView contains placeholder text.
    // Parametter message is inout parameters - if validation fails, in the message is put
    // text: "Exam not specified" which can then be read in calling method.
    func validateForm(message: inout String) -> Bool {
        
        var formIsValid = true
        
        if examTextView.text.containsOnlyWhitespaces() || examTextView.textColor == Model.sharedInstance.placeHolderColor {
            formIsValid = false
        } else {
            formIsValid = true
        }
        
        if formIsValid {
            message = ""
            return true
        } else {
            message = "Exam not specified!"
            return false
        }
        
    }
    
    // Keyboard notifications methods: keyboardWillShow and keyboardWillHide
    
    // Before keyboard shows up, the main view of this view controller is moved up for deltaY
    // points calculated in AppDelegate based on iphone type. The reason of doing this is to
    // prevent that keyboard covers examTextView.
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
    // outside of keyboard and examTextView.
    // Handling of placeholder text - if in text view is placeholder text i.e. if
    // text color is placeholder color, and user begins editing in text view, then
    // text in text view is set to nil and text color is set to defined text color in Model.
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        if examTextView.textColor == Model.sharedInstance.placeHolderColor {
            examTextView.text = nil
            examTextView.textColor = Model.sharedInstance.textColor
        }
    }
    
    // If at the end of editing text view is empty, then text in text view is set to
    // placeholder text and text color in text view is set to placeholder color.
    func textViewDidEndEditing(_ textView: UITextView) {
        if examTextView.text.isEmpty {
            textView.text = "Please, enter exam here"
            textView.textColor = Model.sharedInstance.placeHolderColor
        }
    }
    
    // When user tap outside of examTextView and keyboard, active text view
    // resigns first responder and keyboard is dismissed
    @IBAction func userDidTap () {
        activeTextView?.resignFirstResponder()
    }
    
}

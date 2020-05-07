//
//  SubjectViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 18/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class SubjectViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    // MARK: - Methods
    
    // Functionality that ensures that swipe back gesture causes keyboard to hide is
    // implemented. This functionality prevents some bugs that can be hit when view is
    // vertically moved when keyboard shows up and swipe back gesture is not
    // completed. This is achived by setting delegate of
    // interactivePopGestureRecognizer to self, implementing
    // UIGestureRecognizerDelegate protocol and implementing  protocol method:
    // gestureRecognizerShouldBegin. When swipe back gesture is done
    // resignFirstResponder is send to the application. This way keyboard is hidden
    // when swipe back gesture starts regardless which view currently has first
    // responder status.
    // Autocorrection is disabled on subjectTextField.
    // If currentSubject variable from Model is not nil, its name is displayed in
    // subjectTextField initially. Otherwise, in subjectTextField is displayed
    // placeholder text: Please, enter new subject here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        subjectTextField.autocorrectionType = .no
        if Model.sharedInstance.currentSubject != nil {
            subjectTextField.text = Model.sharedInstance.currentSubject?.name
        }
        
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //Swipe back gesture causes keyboard to hide
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        return true
    }
    
    // MARK: - Outlets
    @IBOutlet weak var subjectTextField: UITextField!
    
    // MARK: - Local variables
    private var activeTextField: UITextField?
    
    // Setting active text field for purpose of hiding keyboard when the user tap
    // outside of keyboard and subjectTextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    // MARK: - Other methods
    
    // When user tap outside of subjectTextField and keyboard, active text field
    // resigns first responder and keyboard is dismissed
    @IBAction func userDidTap(sender: UITapGestureRecognizer?) {
        activeTextField?.resignFirstResponder()
        //print("userDidTap")
    }
    
    // When user presses return, keyboard is dismissed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userDidTap(sender: nil)
        return true
    }
    
    // Validatig form i.e. subjectTextField.
    // This method returns false if subjectTextField contains only whitespaces i. e.
    // spaces, tabs and carriage returns. Parametter message is inout parameters -
    // if validation fails, in the message is put text: "Subject not specified"
    // which can then be read in calling method.
    func validateForm(message: inout String) -> Bool {
        
        var formIsValid = true
                
        if (subjectTextField.text?.containsOnlyWhitespaces())! {
            formIsValid = false
        } else {
            formIsValid = true
        }
        
        if formIsValid {
            message = ""
            return true
        } else {
            message = "Subject not specified!"
            return false
        }
    
    }
    
    // This method saves subject entered or changed. It is not allowed to override
    // already existing subject. If subject has related timetable items, homeworks
    // or exams the user is informed about that before subject is updated. Only if
    // user confirms, the subject is updated.
    @IBAction func saveButtonClicked() {
        
        var message: String = ""
        
        if validateForm(message: &message) == false {
            informUser(controller: self, title: "Error validating form", message: message, okTitle: "Ok", okActionStyle: .default, okAction: { (action) in
                
            })
            return
        }
        
        if let subject = CoreDataManager.sharedInstance.fetchSubject(name: subjectTextField.text!){
            if Model.sharedInstance.currentSubject == nil || subject != Model.sharedInstance.currentSubject {
                informUser(controller: self, title: "Error saving data", message: "This subject already exists! If you want to change this subject, please select it on the Subjects screen.", okTitle: "OK", okActionStyle: .default, okAction: nil)
                return
            }
        }
        
        if Model.sharedInstance.currentSubject == nil {
            var maxSeqNo = CoreDataManager.sharedInstance.fetchSubjectMaxSeqNo()
            if maxSeqNo == nil {
                maxSeqNo = 0
            } else {
                maxSeqNo! +=  1
            }
            CoreDataManager.sharedInstance.saveSubject(seqNo: Int64(maxSeqNo!), name: subjectTextField.text!)
            //print (maxSeqNo!)
            self.navigationController?.popViewController(animated: true)
        } else {
            if Model.sharedInstance.currentSubject?.name == subjectTextField.text {
                self.navigationController?.popViewController(animated: true)
                return
            }
            if CoreDataManager.sharedInstance.existsTimetableItemFor(subject: Model.sharedInstance.currentSubject!) {
                askUser(
                    controller: self,
                    title: "Updating subject",
                    message: "This subject has related timetable items. If you change its name, all related timetable items belonging to it, will belong to this new subject name.  If the subject has related homework assignments and exams they will also belong to this new subject name. Tap Update to continue or Cancel to cancel this action",
                    okTitle: "Update",
                    cancelTitle: "Cancel",
                    okActionStyle: UIAlertAction.Style.default,
                    cancelActionStyle: UIAlertAction.Style.cancel,
                    okAction: { (action) in
                        Model.sharedInstance.currentSubject?.name = self.subjectTextField.text
                        CoreDataManager.sharedInstance.saveContext()
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    },
                    cancelAction: { (action) in
                        return
                    })
            } else if CoreDataManager.sharedInstance.existsHomeworkFor(subject: Model.sharedInstance.currentSubject!) {
                askUser(
                    controller: self,
                    title: "Updating subject",
                    message: "This subject has related homework assignments. If you change its name, all related homework assignments belonging to it, will belong to this new subject name.  If the subject has related exams they will also belong to this new subject name. Tap Update to continue or Cancel to cancel this action",
                    okTitle: "Update",
                    cancelTitle: "Cancel",
                    okActionStyle: UIAlertAction.Style.default,
                    cancelActionStyle: UIAlertAction.Style.cancel,
                    okAction: { (action) in
                        Model.sharedInstance.currentSubject?.name = self.subjectTextField.text
                        CoreDataManager.sharedInstance.saveContext()
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                },
                    cancelAction: { (action) in
                        return
                })
            } else if CoreDataManager.sharedInstance.existsExamFor(subject: Model.sharedInstance.currentSubject!) {
                askUser(
                    controller: self,
                    title: "Updating subject",
                    message: "This subject has related exams. If you change its name, all related exams belonging to it, will belong to this new subject name. Tap Update to continue or Cancel to cancel this action",
                    okTitle: "Update",
                    cancelTitle: "Cancel",
                    okActionStyle: UIAlertAction.Style.default,
                    cancelActionStyle: UIAlertAction.Style.cancel,
                    okAction: { (action) in
                        Model.sharedInstance.currentSubject?.name = self.subjectTextField.text
                        CoreDataManager.sharedInstance.saveContext()
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                },
                    cancelAction: { (action) in
                        return
                })
            }
            else {
                    Model.sharedInstance.currentSubject?.name = self.subjectTextField.text
                    CoreDataManager.sharedInstance.saveContext()
                    self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

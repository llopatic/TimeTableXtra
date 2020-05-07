//
//  InfoViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 22/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var infoDoneSwitch: UISwitch!
    
    // MARK: - Local variables
    
    private var keyboardPresented = false
    private var activeTextView: UITextView?
    private var entryDate: Date?
    private var info: Information?
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
        
        // Designing infoTextView, its attributes are defined in Model
        infoTextView.layer.cornerRadius = Model.sharedInstance.cornerRadius
        infoTextView.backgroundColor = Model.sharedInstance.backgroundColor
        infoTextView.layer.borderWidth = Model.sharedInstance.borderWidth
        infoTextView.layer.borderColor = Model.sharedInstance.borderColor
        
        // Defining method that will be run when keyboard shows up
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(InfoViewController.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        // Defining method that will be run when keyboard hides
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(InfoViewController.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        // If navigating from TimetablePlusViewController, currentInformation in Model is set to nil
        // and lastInformation in Model can be set or not. If it is set then information with latest
        // entry date is shown in this view controller and user can change its attributes, otherwise
        // i.e. if lastInformation variable is nil then user creates (inserts) new information.
        // If navigating from InfoHistViewController, currentInformation in Model is set and user can
        // change currentInformation's attributes. The following attributes are defined for information:
        // entry date, information and read flag. When inserting new information, entry date is
        // initially set to current date, information to placeholder text "Please, enter information
        // here" and done flag to false.
        // formMode variable is set to Insert if new information is created and to Update if existing
        // information is updated.
        // To ensure that currentInformation in Model is correctly set, in viewWillDisappear method
        // this variable is set to nil.
        if Model.sharedInstance.currentInformation != nil {
            info = Model.sharedInstance.currentInformation
        } else {
            if let lastInformation = Model.sharedInstance.lastInformation {
                info = lastInformation
            } else {
                info = nil
            }
        }
        entryDate = truncate(date: Date())
        if info != nil {
            datePicker.date = info!.entryDate! as Date
            infoTextView.text = info!.information
            infoTextView.textColor = Model.sharedInstance.textColor
            infoDoneSwitch.isOn = info!.done
            formMode = "Update"
        } else {
            datePicker.date = entryDate! as Date
            infoTextView.text = "Please, enter information here"
            infoTextView.textColor = Model.sharedInstance.placeHolderColor
            infoDoneSwitch.isOn = false
            formMode = "Insert"
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Model.sharedInstance.currentInformation = nil
    }
    
    // This method saves information entered or changed.
    // Information must be provided.
    // It is not allowed to override already existing information.
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        
        var message: String = ""
        
        if validateForm(message: &message) == false {
            informUser(controller: self, title: "Error validating form", message: message, okTitle: "Ok", okActionStyle: .default, okAction: { (action) in
                
            })
            return
        }
        
        if let info = CoreDataManager.sharedInstance.fetchInformation(forDate: datePicker.date) {
            if self.info != info || self.info == nil {
                informUser(controller: self, title: "Error saving data", message: "Information for selected date already exists! If you want to change this information, please select it on the Information screen in History.", okTitle: "Ok", okActionStyle: .default, okAction: { (action) in
                    
                })
                return
            }
        }
        
        
        if formMode == "Update" {
            //update
            info!.entryDate = datePicker.date as NSDate
            info!.information = infoTextView.text
            info!.done = infoDoneSwitch.isOn
            CoreDataManager.sharedInstance.saveContext()
            self.navigationController?.popViewController(animated: true)        }
        else {
            //insert
            var maxSeqNo = CoreDataManager.sharedInstance.fetchInfoMaxSeqNo()
            if maxSeqNo == nil {
                maxSeqNo = 0
            } else {
                maxSeqNo! +=  1
            }
            CoreDataManager.sharedInstance.saveInfo(seqNo: Int64(maxSeqNo!), entryDate: datePicker.date, information: infoTextView.text!, done: infoDoneSwitch.isOn)
            //print (maxSeqNo!)
            self.navigationController?.popViewController(animated: true)
        }
        
    }

    // Validatig form i.e. infoTextView.
    // This method returns false if infoTextView contains only whitespaces i. e.
    // spaces, tabs and carriage returns or if infoTextView contains placeholder text.
    // Parameter message is inout parameters - if validation fails, in the message is put
    // text: "Information not specified" which can then be read in calling method.
    func validateForm(message: inout String) -> Bool {
        
        var formIsValid = true
        
        if infoTextView.text.containsOnlyWhitespaces() || infoTextView.textColor == Model.sharedInstance.placeHolderColor {
            formIsValid = false
        } else {
            formIsValid = true
        }
        
        if formIsValid {
            message = ""
            return true
        } else {
            message = "Information not specified!"
            return false
        }
    }
    
    
    
    // Keyboard notifications methods: keyboardWillShow and keyboardWillHide
    
    // Before keyboard shows up, the main view of this view controller is moved up for deltaY
    // points calculated in AppDelegate based on iphone type. The reason of doing this is to
    // prevent that keyboard covers infoTextView.
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
    // outside of keyboard and infoTextView.
    // Handling of placeholder text - if in text view is placeholder text i.e. if
    // text color is placeholder color, and user begins editing in text view, then
    // text in text view is set to nil and text color is set to defined text color in Model.
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        if infoTextView.textColor == Model.sharedInstance.placeHolderColor {
            infoTextView.text = nil
            infoTextView.textColor = Model.sharedInstance.textColor
        }
    }
    
    // If at the end of editing text view is empty, then text in text view is set to
    // placeholder text and text color in text view is set to placeholder color.
    func textViewDidEndEditing(_ textView: UITextView) {
        if infoTextView.text.isEmpty {
            textView.text = "Please, enter information here"
            textView.textColor = Model.sharedInstance.placeHolderColor
        }
    }
    
    // When user tap outside of infoTextView and keyboard, active text view
    // resigns first responder and keyboard is dismissed
    @IBAction func userDidTap () {
        activeTextView?.resignFirstResponder()
    }

}

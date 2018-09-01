//
//  SettingsViewController.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 16/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var classPeriodDurationStepper: UIStepper!
    @IBOutlet weak var pauseDurationStepper: UIStepper!
    @IBOutlet weak var classPeriodDurationTextField: UITextField!
    @IBOutlet weak var pauseDurationTextField: UITextField!
    @IBOutlet weak var subjectsButton: UIButton!

    // MARK: - Methods
    
    // After fetching settings from database display them in corresponding
    // text fields and sets corresponding steppers' values.
    // Design Subjects button.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        CoreDataManager.sharedInstance.fetchSettings()
        
        self.classPeriodDurationTextField.text = "\(Model.sharedInstance.classPeriodDuration) min"
        self.classPeriodDurationStepper.value = Double(Model.sharedInstance.classPeriodDuration)
        self.pauseDurationTextField.text = "\(Model.sharedInstance.pauseDuration) min"
        self.pauseDurationStepper.value = Double(Model.sharedInstance.pauseDuration)
        
        self.subjectsButton.layer.borderWidth = 1
        self.subjectsButton.layer.borderColor = self.view.tintColor.cgColor
        self.subjectsButton.layer.cornerRadius = 5
        
    }
    
    // Display steppers' values in corresponding text fields when
    // steppers' values are changed
    @IBAction func stepperDidValueChanged(sender: UIStepper) {
        
        var  textField: UITextField? = nil
        
        if sender == classPeriodDurationStepper {
            textField = classPeriodDurationTextField
        } else if sender == pauseDurationStepper {
            textField = pauseDurationTextField
        }
        
        textField?.text = "\(Int(sender.value)) min"
    }
    
    // Save selected settings to database and after that fetch them from
    // database and set corresponding variables in Model using fetchSettings
    // method from CoreDataManager
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        Model.sharedInstance.currentSettings?.classPeriodDuration = Int64(self.classPeriodDurationStepper.value)
        Model.sharedInstance.currentSettings?.pauseDuration = Int64(self.pauseDurationStepper.value)
        CoreDataManager.sharedInstance.saveContext()
        
        CoreDataManager.sharedInstance.fetchSettings()
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

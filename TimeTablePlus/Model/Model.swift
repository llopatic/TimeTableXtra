//
//  Model.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 12/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import Foundation
import UIKit

class Model {
    
    // MARK: - Singleton
    static let sharedInstance = Model()
    private init() {}
    
    // MARK: - Managed Object Arrays
    // Data is fetched from database and then saved into the following arrays in Model:
    var subjects = [Subject]()
    var days = [Day]()
    var timetables = [Timetable]()
    var items = [Item]()
    var settings = [Settings]()
    var homeworks = [Homework]()
    var exams = [Exam]()
    var information = [Information]()
    
    // MARK: - Current/Last Managed Objects
    // Current or last instances of managed objects fetched from database
    // Mostly used when user navigates between screens
    var currentTimetable: Timetable?
    var currentDay: Day?
    var currentSubject: Subject?
    var currentItem: Item?
    var lastHomework: Homework?
    var currentSettings: Settings?
    var currentHomework: Homework?
    var currentExam: Exam?
    var lastExam: Exam?
    var currentInformation: Information?
    var lastInformation: Information?
    
    // MARK: - Settings
    var interval = 0 // interval in picker, default 5 from plist file, cannot be changed in application
    var classPeriodDuration = 0 // default 45 from plist file, can be changed in application to multiples of 5
    var pauseDuration = 0 // default 5 from plist file, can be changed in application to multiples of 5
    
    // MARK: - amPm
    // This method returns 0 for am indicator or 1 for pm indicator for given time of the day expressed in minutes
    func amPm(totalMinutes: Int) -> Int {
        // Returns 0 for am and 1 for pm
        var amPm = 0
        if totalMinutes < 12*60 {
            //am
            amPm = 0
        } else {
            //pm
            amPm = 1
        }
        return amPm
    }
    
    // MARK: - TextView attributes
    var placeHolderColor = UIColor.lightGray
    var textColor = UIColor.black
    var backgroundColor = UIColor(
        red: 235/255,
        green:235/255,
        blue: 235/255,
        alpha: 0.0 )
    var borderWidth = CGFloat(1.0)
    var borderColor = UIColor.lightGray.cgColor
    var cornerRadius = CGFloat(15)
    
    // MARK: - Vertical shift
    // Vertical shift of main controller's view when keyboard is displayed or hidden
    var deltaY: CGFloat!

}

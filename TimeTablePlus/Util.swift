//
//  Util.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 20/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

// Utility class

import Foundation
import UIKit

// MARK: - Utility methods

// This method displays an alert with specified parameters.
// Two actions can be defined: OK action and Cancel action.
func askUser(
    controller: UIViewController,
    title: String,
    message: String,
    okTitle: String,
    cancelTitle: String,
    okActionStyle: UIAlertAction.Style,
    cancelActionStyle: UIAlertAction.Style,
    okAction: ((UIAlertAction) -> Void)?,
    cancelAction:((UIAlertAction) -> Void)?)
{
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert)
    let okAction = UIAlertAction(title: okTitle, style: okActionStyle, handler: okAction)
    let cancelAction = UIAlertAction(title: cancelTitle, style: cancelActionStyle, handler: cancelAction)
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    alert.preferredAction = cancelAction
    controller.present(alert, animated: true)
}

// This method displays alert as menu with specified actions as menu items.
// Actions are specified as an array of dictionaries where each dictionary
// specifies an action to be displayed as an option in menu.
func askUserForOption(
    controller: UIViewController,
    title: String,
    message: String,
    actions: Array<Dictionary<String, Any>>)
{
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .actionSheet)

    for action in actions {
        let alertAction = UIAlertAction(
            title: action["actionTitle"] as? String,
            style: action["actionStyle"] as! UIAlertAction.Style,
            handler: action["actionHandler"] as? (UIAlertAction) -> Void)
        alert.addAction(alertAction)
    }
    
    controller.present(alert, animated: true)
}

// This method displays an informative alert.
// User can only confirm that message is read.
// Only OK action can be defined which is run when user confirms that message is read.
func informUser(
    controller: UIViewController,
    title: String,
    message: String,
    okTitle: String,
    okActionStyle: UIAlertAction.Style,
    okAction: ((UIAlertAction) -> Void)?)
{
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert)
    let okAction = UIAlertAction(title: okTitle, style: okActionStyle, handler: okAction)
    alert.addAction(okAction)
    alert.preferredAction = okAction
    controller.present(alert, animated: true)
}

// This method truncate given date to midnight of given date i.e. time component of the date is truncated
func truncate(date: Date) -> Date {
    
    let calendar = NSCalendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)

    let dateComponents = DateComponents(
        calendar: .current,
        timeZone: Calendar.current.timeZone,
        year: year,
        month: month,
        day: day)

    return dateComponents.date!
}

// String structure is extended with method containsOnlyWhitespaces that checks whether given string contains only whitespaces i.e. spaces, tabs and carriage returns. If it is true, the method returns true else returns false.
extension String {
    
    func containsOnlyWhitespaces () -> Bool {
        
        let stringArray = self.map { (c) -> String in
            if String(c) == " " || String(c) == "\t" || String(c) == "\n" {
                return  ""
            } else {
                return String(c)
            }
        }
        
        for c in stringArray {
            if c != "" {
                return false
            }
        }
        
        return true
    
    }
}

// Ensure that SegmentedControl has look and feel as similar as possible to look and feel in ios12 and before
extension UISegmentedControl {
    func ensureiOS12Style(){
        if #available(iOS 13.0, *) {
            selectedSegmentTintColor =  UIColor(red: 0.08235294118, green: 0.4784313725, blue: 1, alpha: 1)
            setTitleTextAttributes([.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .selected)
        }
    }
}

// Print path of sqlite file
func printDatabasePath() {
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docsDir = dirPaths[0]
    let databasePath = docsDir.replacingOccurrences(of: "Documents", with: "Library/Application support")
    print("Database path: \(databasePath)")
}

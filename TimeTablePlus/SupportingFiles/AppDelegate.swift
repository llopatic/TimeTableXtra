//
//  AppDelegate.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 11/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Populate certain database tables at first run of the application
        CoreDataManager.sharedInstance.populateTablesAtFirstRun()
        
        // Fetch settings from database table Settings and save them in Model variables
        CoreDataManager.sharedInstance.fetchSettings()
        
        //Fetch days from database table Days and save them in the array days in Model
        if let results = CoreDataManager.sharedInstance.fetchDays() {
            Model.sharedInstance.days = results
        }
        
        //Fetch timetables from database table Timetables and save them in the array timetables in Model
        if let results = CoreDataManager.sharedInstance.fetchTimetables() {
            Model.sharedInstance.timetables = results
        }

        // Defining vertical shift of main controller's view when keyboard is displayed or hidden based on screen size i.e. iphone type
        //        // Normal Screen Bounds - Detect Screen size in Points.
        //        let width = UIScreen.main.bounds.width
        //        let height = UIScreen.main.bounds.height
        //        print("\n width:\(width) \n height:\(height)")
        //
        //        // Native Bounds - Detect Screen size in Pixels.
        //        let nWidth = UIScreen.main.nativeBounds.width
        //        let nHeight = UIScreen.main.nativeBounds.height
        //        print("\n Native Width:\(nWidth) \n Native Height:\(nHeight)")
        switch UIScreen.main.bounds.height {
            case 812:
                //iphone 10
                Model.sharedInstance.deltaY = 0
            case 736:
                //iphone 8+
                Model.sharedInstance.deltaY = 0
            case 667:
                //iphone 8
                Model.sharedInstance.deltaY = 0
            case 568:
                //iphone 5s
                Model.sharedInstance.deltaY = 45
            default:
                Model.sharedInstance.deltaY = 50
        }
        
        //printDatabasePath()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        // Dismiss alerts before application goes to background
        let navigationController = application.windows[0].rootViewController as! UINavigationController
        let activeViewController = navigationController.visibleViewController
        activeViewController?.dismiss(animated: true)
        
        // Hide keyboard before application goes to background
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.sharedInstance.saveContext()
    }

}


//
//  CoreDataManager.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 11/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Core Data stack

class CoreDataManager {
    
    // Singleton
    static let sharedInstance = CoreDataManager()
    private init () {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TimeTablePlus")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Application methods
    
    // Save (insert) value of parameter firstRunCompleted in the database table FirstRunCompleted
    func saveFirstRunCompleted(firstRunCompleted: Bool){
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "FirstRunCompleted", in: context)
        let moFirstRunCompleted = NSManagedObject(entity: entityDescription!, insertInto: context) as! FirstRunCompleted
        moFirstRunCompleted.firstRunCompleted = firstRunCompleted
        saveContext()
    }
    
    // Save (insert) given sequence number and subject in database table Subjects (entity Subject)
    func saveSubject(seqNo: Int64, name: String){
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Subject", in: context)
        let subject = NSManagedObject(entity: entityDescription!, insertInto: context) as! Subject
        subject.name = name
        subject.seqNo = seqNo
        saveContext()
    }
    
    // Save (insert) subjects from plist file Subjects_EN.plist to database table Subjects.
    func populateSubjectsTableAtFirstRun() {
        let path = Bundle.main.path(forResource: "Subjects_EN", ofType: "plist")!
        let plistArray = NSArray(contentsOfFile: path) as! Array<String>
        for (index, subject) in plistArray.enumerated() {
            saveSubject(seqNo: Int64(index), name: subject)
        }
        
    }

    // Save (insert) given sequence number and day in database table Days (entity Day)
    func saveDay(seqNo: Int64, name: String){
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Day", in: context)
        let day = NSManagedObject(entity: entityDescription!, insertInto: context) as! Day
        day.name = name
        day.seqNo = seqNo
        saveContext()
    }

    // Save (insert) days from plist file Days.plist to database table Days.
    func populateDaysTableAtFirstRun() {
        let path = Bundle.main.path(forResource: "Days", ofType: "plist")!
        let plistArray = NSArray(contentsOfFile: path) as! Array<String>
        for (index, day) in plistArray.enumerated() {
            saveDay(seqNo: Int64(index), name: day)
        }
    }
   
    // Save (insert) given sequence number and timetable in database table Timetables (entity Timetable)
    func saveTimetable(seqNo: Int64, name: String){
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Timetable", in: context)
        let timetable = NSManagedObject(entity: entityDescription!, insertInto: context) as! Timetable
        timetable.seqNo = seqNo
        timetable.name = name
        saveContext()
    }
    
    // Save (insert) timetables from plist file Timetables.plist to database table Timetables.
    func populateTimetablesTableAtFirstRun() {
        let path = Bundle.main.path(forResource: "Timetables", ofType: "plist")!
        let plistArray = NSArray(contentsOfFile: path) as! Array<String>
        for (index, timetable) in plistArray.enumerated() {
            saveTimetable(seqNo: Int64(index), name: timetable)
        }
    }
    
    // Save (insert) given settings in database table Settings (entity Settings)
    func saveSettings(classPeriodDuration: String, pauseDuration: String, intervalInTimePicker: String){
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Settings", in: context)
        let settings = NSManagedObject(entity: entityDescription!, insertInto: context) as! Settings
        settings.classPeriodDuration = Int64(classPeriodDuration)!
        settings.pauseDuration = Int64(pauseDuration)!
        settings.intervalInTimePicker = Int64(intervalInTimePicker)!
        saveContext()
    }
    
    // Save (insert) settings from plist file Settings.plist to database table Settings.
    func populateSettingsTableAtFirstRun() {
        let path = Bundle.main.path(forResource: "Settings", ofType: "plist")!
        let plistDictionary = NSDictionary(contentsOfFile: path) as! Dictionary<String,String>
        saveSettings(classPeriodDuration: plistDictionary["classPeriodDuration"]!,
                    pauseDuration: plistDictionary["pauseDuration"]!,
                    intervalInTimePicker: plistDictionary["intervalInTimePicker"]!)
    }
    
    // Initially, the table FirstRunCompleted is empty. At first run, it is populated with value true.
    // It means that this table is empty only when the application is first run.
    // Condition in the following code: "if results.count == 0" means "if this application is first run".
    // So, when the application is first run the following tables are populated:
    // FirstRunCompleted - with value true
    // Subjects - with data from corresponding plist file: Subjects_EN.plist
    // Days - with data from corresponding plist file: Days.plist
    // Timetables - with data from corresponding plist file: Timetables.plist
    // Settings - with data from corresponding plist file: Settings.plist
    func populateTablesAtFirstRun() {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FirstRunCompleted")
        var results = [FirstRunCompleted]()
        
        do {
            results = try context.fetch(request) as! [FirstRunCompleted]
        } catch let error as NSError {
            print ("Could not fetch FirstRunCompleted: \(error), \(error.userInfo)")
        }
        
        if results.count == 0 {
          //populate following tables from plist files: Subjects, Days, Timetables and Settings
          //print ("Populating tables at first run ...")
          saveFirstRunCompleted(firstRunCompleted: true)
          populateSubjectsTableAtFirstRun()
          populateDaysTableAtFirstRun()
          populateTimetablesTableAtFirstRun()
          populateSettingsTableAtFirstRun()
        }
        
    }
    
    // This method fetches subjects from database table Subjects and returns them in the array.
    // The data is sorted by sequence number meaning the sequence corresponds to the order in the plist file and the times of adding new subjects through the application.
    func fetchSubjects() -> [Subject]? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")
        request.returnsObjectsAsFaults = false
        let sort = NSSortDescriptor(key: "seqNo", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            let results = try context.fetch(request) as! [Subject]
            return results
        } catch let error as NSError {
            print ("Could not fetch Subjects: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // This method returns max sequence number in the database table Subjects
    func fetchSubjectMaxSeqNo() -> Int? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")
        
        do {
            let results = try context.fetch(request) as! [Subject]
            if results.count > 0 {
                return Int(results.sorted(by: {$0.seqNo > $1.seqNo})[0].seqNo)
            } else {
                return nil
            }
        } catch let error as NSError {
            print ("Could not fetch Subjects: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // Fetch subject for given subject name
    func fetchSubject(name: String) -> Subject? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")
        request.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "name = %@", name)
        request.predicate = predicate
        do {
            let results = try context.fetch(request) as! [Subject]
            if results.count > 0 {
                return results[0]
            } else {
                return nil
            }
        } catch let error as NSError {
            print ("Could not fetch Subjects: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // This method fetches days from database table Days and returns them in the array.
    // The data is sorted by sequence number meaning the sequence corresponds to the order in the plist file.
    func fetchDays() -> [Day]? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        request.returnsObjectsAsFaults = false
        let sort = NSSortDescriptor(key: "seqNo", ascending: true)
        request.sortDescriptors = [sort]
        do {
            let results = try context.fetch(request) as! [Day]
            return results
        } catch let error as NSError {
            print ("Could not fetch Days: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // This method fetches timetables from database table Timetables and returns them in the array.
    // The data is sorted by sequence number meaning the sequence corresponds to the order in the plist file.
    func fetchTimetables() -> [Timetable]? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Timetable")
        request.returnsObjectsAsFaults = false
        let sort = NSSortDescriptor(key: "seqNo", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            let results = try context.fetch(request) as! [Timetable]
            return results
        } catch let error as NSError {
            print ("Could not fetch Timetables: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // This method returns timetable name for the given sequence number
    func fetchTimetableName(seqNo: Int) -> String? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Timetable")
        let predicate = NSPredicate(format: "seqNo = %@", NSNumber(value: seqNo))
        request.predicate = predicate
        do {
            let results = try context.fetch(request) as! [Timetable]
            return results[0].name
        } catch let error as NSError {
            print ("Could not fetch Timetables: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // This method returns array of timetable items for the current timetable and day. Current timetable and day are defined in Model variables Model.sharedInstance.currentTimetable and Model.sharedInstance.currentDay. Returned array is sorted by field intFrom i.e. by time ascending, but if two items have the same intFrom then items are sorted by subject name ascending.
    func fetchItems() -> [Item]? {
        
        let timetable = Model.sharedInstance.currentTimetable
        let day = Model.sharedInstance.currentDay
        let results = timetable?.relItems?.filter{(day?.relItems?.contains($0))!} as? [Item]
        //return results?.sorted(by: { $0.intFrom < $1.intFrom })
        return results?.sorted(by: {
            if $0.intFrom == $1.intFrom {
                return $0.relSubject!.name!.caseInsensitiveCompare($1.relSubject!.name!) == .orderedAscending
            } else {
                return $0.intFrom < $1.intFrom
            }
        })
    }
    
    // This method fetches settings from database table Settings and sets settings variables in Model
    func fetchSettings() {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request) as! [Settings]
            Model.sharedInstance.classPeriodDuration = Int(results[0].classPeriodDuration)
            Model.sharedInstance.pauseDuration = Int(results[0].pauseDuration)
            Model.sharedInstance.interval = Int(results[0].intervalInTimePicker)
            Model.sharedInstance.currentSettings = results[0]
        } catch let error as NSError {
            print ("Could not fetch Settings: \(error), \(error.userInfo)")
        }
    }
    
    // Converting time given in string like: 08:00 am into total minutes from midnight to this timestamp.
    func totalMinutes(time: String) -> Int {
        let arrTime = time.components(separatedBy: " ")
        let amPm = arrTime[1]
        let arrHoursMinutes = arrTime[0].components(separatedBy: ":")
        var hours = Int(arrHoursMinutes[0])!
        let minutes = Int(arrHoursMinutes[1])!
        if amPm == "am" && hours == 12 {
            hours = hours - 12
        } else if amPm == "pm" && hours < 12 {
            hours = hours + 12
        }
        let totalMinutes = hours * 60 + minutes
        return totalMinutes
    }
    
    // Save given timetable item into database table Items.
    func saveTimetableItem(timetable: Timetable, day: Day, from: String, to: String, subject: Subject ) {
        
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Item", in: context)
        let item = NSManagedObject(entity: entityDescription!, insertInto: context) as! Item
        
        item.relTimetable = timetable
        item.relDay = day
        item.from = from
        item.to = to
        item.relSubject = subject
        item.intFrom = Int64(totalMinutes(time: from))
        item.intTo = Int64(totalMinutes(time: to))
        
        saveContext()
        
    }
    
    // Delete given managed object from corresponding database table.
    func deleteEntity (_ entity: NSManagedObject) {
        let context = persistentContainer.viewContext
        context.delete(entity)
        saveContext()
    }
    
    // This method returns true if given timetable item is unique i.e. does not exist in database yet
    func isUniqueItem(timetable: Timetable, day: Day, from: String, to: String, subject: Subject) -> Bool
    {
            let context = persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
            let predicate = NSPredicate(format: "from = %@ AND to = %@", from, to)
            request.returnsObjectsAsFaults = false
            request.predicate = predicate
            var items = [Item]()
        
            do {
                items = try context.fetch(request) as! [Item]
            } catch let error as NSError {
                print ("Could not fetch Items: \(error), \(error.userInfo)")
                return false
            }
        
        var results = timetable.relItems?.filter{(day.relItems?.contains($0))!} as? [Item]
        results = results?.filter{(subject.relItems?.contains($0))!}
        results = results?.filter{items.contains($0)}
        
        if results == nil {
            return true
        }
        
        if results!.count == 0 {
            return true
        } else {
            return false
        }
        
    }
    
    // This method returns timetable item based on the parameters provided
    func fetchItem(timetable: Timetable, day: Day, from: String, to: String, subject: Subject) -> Item?
    {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let predicate = NSPredicate(format: "from = %@ AND to = %@", from, to)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        var items = [Item]()
        
        do {
            items = try context.fetch(request) as! [Item]
        } catch let error as NSError {
            print ("Could not fetch Items: \(error), \(error.userInfo)")
            return nil
        }
        
        var results = timetable.relItems?.filter{(day.relItems?.contains($0))!} as? [Item]
        results = results?.filter{(subject.relItems?.contains($0))!}
        results = results?.filter{items.contains($0)}
        
        if results == nil {
            return nil
        }
        
        if results!.count == 0 {
            return nil
        } else {
            return results![0]
        }
        
    }
    
    // This method returns max sequence number in the table Homeworks
    func fetchHomeworkMaxSeqNo() -> Int? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Homework")
        
        do {
            let results = try context.fetch(request) as! [Homework]
            if results.count > 0 {
                return Int(results.sorted(by: {$0.seqNo > $1.seqNo})[0].seqNo)
            } else {
                return nil
            }
        } catch let error as NSError {
            print ("Could not fetch Homework: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // This method saves (inserts) homework with given parameters
    func saveHomework(seqNo: Int64, entryDate: Date, subject: Subject, hwDesc: String, done: Bool){
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Homework", in: context)
        let homework = NSManagedObject(entity: entityDescription!, insertInto: context) as! Homework
        homework.seqNo = seqNo
        homework.entryDate = (entryDate as NSDate)
        homework.relSubject = subject
        homework.hwDesc = hwDesc
        homework.done = done
        saveContext()
    }
 
    // This method returns the array of homeworks based on the parameters provided.
    // It returns all homeworks:
    // - entered on the date given if forDate parameter is given
    // - for the subject given if andSubject parameter is given
    // - which are done if andDone is true or which are not done yet if andDone is false - if parameter andDone is given
    // Homeworks in returned array are ordered by:
    // - entry date ascending if orderByDateAsc is true or entry date descending if orderByDateAsc is false - if orderByDateAsc is given
    // - subject ascending if orderBySubjectAsc is true or subject descending if orderBySubjectAsc is false - if orderBySubjectAsc is given
    // By default homeworks in returned array are firstly sorted by entry date and then by subject.
    // If we want to order by subject first and then by entry date, then the parameter firstOrderByDate should be set to false.
    func fetchHomeworks(forDate date: Date?, andSubject subject: Subject?, andDone done: Bool?,
                        orderByDateAcs: Bool?, orderBySubjectAsc: Bool?, firstOrderByDate: Bool?) -> [Homework]? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Homework")
        var subpredicates = [NSPredicate(format: "1 = 1")]
        var sortDescriptors = [NSSortDescriptor]()

        if date != nil {
            subpredicates.append(NSPredicate(format: "entryDate = %@", date! as NSDate))
        }
        
        if subject != nil {
            subpredicates.append(NSPredicate(format: "relSubject = %@", subject!))
        }

        if done != nil {
            subpredicates.append(NSPredicate(format: "done = %@", NSNumber(booleanLiteral: done!)))
        }
        
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: subpredicates)
        
        request.predicate = andPredicate
        
        request.returnsObjectsAsFaults = false

        if let orderByDateAcsending = orderByDateAcs {
            if orderByDateAcsending {
                sortDescriptors.append(NSSortDescriptor(key: "entryDate", ascending: true))
            } else {
                sortDescriptors.append(NSSortDescriptor(key: "entryDate", ascending: false))
            }
        }
        
        if let orderBySubjectAcsending = orderBySubjectAsc {
            if orderBySubjectAcsending {
                sortDescriptors.append(NSSortDescriptor(key: "relSubject.name", ascending: true))
            } else {
                sortDescriptors.append(NSSortDescriptor(key: "relSubject.name", ascending: false))
            }
        }
        
        if sortDescriptors.count > 0 {
            if firstOrderByDate != nil {
                if firstOrderByDate == false && sortDescriptors.count > 1 {
                    let temp = sortDescriptors[0]
                    sortDescriptors[0] = sortDescriptors[1]
                    sortDescriptors[1] = temp
                }
            }
            request.sortDescriptors = sortDescriptors
        }
        
        do {
            let homeworks = try context.fetch(request) as! [Homework]
            //print (homeworks)
            return homeworks
        } catch let error as NSError {
            print ("Could not fetch Homework: \(error), \(error.userInfo)")
            return nil
        }
        
    }
    
    // This method returns true if there is at least one homework for the subject given that is not done yet.
    // It returns false if all homeworks for the subject given are already done.
    func existsPendingHomework(forSubject subject: Subject) -> Bool {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Homework")
        let predicate = NSPredicate(format: "done = %@ AND relSubject = %@", NSNumber(value: false), subject)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        var homeworks = [Homework]()
        
        do {
            homeworks = try context.fetch(request) as! [Homework]
            if homeworks.count > 0 {
                return true
            } else {
                return false
            }
        } catch let error as NSError {
            print ("Could not fetch Homework: \(error), \(error.userInfo)")
            return false
        }
    }
    
    // This method returns homework for given date and subject. If there is no homework for parameters given it returns nil.
    func fetchHomework(forDate entryDate: Date, andSubject subject: Subject) -> Homework? {
        var homework: Homework? = nil
        if let results = CoreDataManager.sharedInstance.fetchHomeworks(forDate: entryDate, andSubject: subject, andDone: nil, orderByDateAcs: nil, orderBySubjectAsc: nil, firstOrderByDate: nil) {
            if results.count > 0 {
                homework = results[0]
            }
        }
        return homework
    }
    
    // This method returns homework with the latest entry date for the subject given.
    func fetchLastHomework(forSubject subject: Subject) -> Homework? {
        var homework: Homework? = nil
        if let results = CoreDataManager.sharedInstance.fetchHomeworks(forDate: nil, andSubject: subject, andDone: nil, orderByDateAcs: false, orderBySubjectAsc: nil, firstOrderByDate: nil) {
            if results.count > 0 {
                homework = results[0]
            }
        }
        return homework
    }
    
    // This method returns max sequence number in the database table Exams
    func fetchExamMaxSeqNo() -> Int? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Exam")
        
        do {
            let results = try context.fetch(request) as! [Exam]
            if results.count > 0 {
                return Int(results.sorted(by: {$0.seqNo > $1.seqNo})[0].seqNo)
            } else {
                return nil
            }
        } catch let error as NSError {
            print ("Could not fetch Exams: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // This method saves (inserts) exam with given parameters
    func saveExam(seqNo: Int64, examDate: Date, subject: Subject, examDesc: String, done: Bool){
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Exam", in: context)
        let exam = NSManagedObject(entity: entityDescription!, insertInto: context) as! Exam
        exam.seqNo = seqNo
        exam.examDate = (examDate as NSDate)
        exam.relSubject = subject
        exam.examDesc = examDesc
        exam.done = done
        saveContext()
    }
    
    // This method returns the array of exams based on the parameters provided.
    // It returns all exams:
    // - with the exam date given if forDate parameter is given
    // - for the subject given if andSubject parameter is given
    // - which are done if andDone is true or which are not done yet if andDone is false - if parameter andDone is given
    // Exams in returned array are ordered by:
    // - exam date ascending if orderByDateAsc is true or exam date descending if orderByDateAsc is false - if orderByDateAsc is given
    // - subject ascending if orderBySubjectAsc is true or subject descending if orderBySubjectAsc is false - if orderBySubjectAsc is given
    // By default exams in returned array are firstly sorted by exam date and then by subject. If we want to order by subject first and then by
    // exam date, then the parameter firstOrderByDate should be set to false.
    func fetchExams(forDate date: Date?, andSubject subject: Subject?, andDone done: Bool?,
                        orderByDateAcs: Bool?, orderBySubjectAsc: Bool?, firstOrderByDate: Bool?) -> [Exam]? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Exam")
        var subpredicates = [NSPredicate(format: "1 = 1")]
        var sortDescriptors = [NSSortDescriptor]()
        
        if date != nil {
            subpredicates.append(NSPredicate(format: "examDate = %@", date! as NSDate))
        }
        
        if subject != nil {
            subpredicates.append(NSPredicate(format: "relSubject = %@", subject!))
        }
        
        if done != nil {
            subpredicates.append(NSPredicate(format: "done = %@", NSNumber(booleanLiteral: done!)))
        }
        
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: subpredicates)
        
        request.predicate = andPredicate
        
        request.returnsObjectsAsFaults = false
        
        if let orderByDateAcsending = orderByDateAcs {
            if orderByDateAcsending {
                sortDescriptors.append(NSSortDescriptor(key: "examDate", ascending: true))
            } else {
                sortDescriptors.append(NSSortDescriptor(key: "examDate", ascending: false))
            }
        }
        
        if let orderBySubjectAcsending = orderBySubjectAsc {
            if orderBySubjectAcsending {
                sortDescriptors.append(NSSortDescriptor(key: "relSubject.name", ascending: true))
            } else {
                sortDescriptors.append(NSSortDescriptor(key: "relSubject.name", ascending: false))
            }
        }
        
        if sortDescriptors.count > 0 {
            if firstOrderByDate != nil {
                if firstOrderByDate == false && sortDescriptors.count > 1 {
                    let temp = sortDescriptors[0]
                    sortDescriptors[0] = sortDescriptors[1]
                    sortDescriptors[1] = temp
                }
            }
            request.sortDescriptors = sortDescriptors
        }
        
        do {
            let exams = try context.fetch(request) as! [Exam]
            //print (exams)
            return exams
        } catch let error as NSError {
            print ("Could not fetch Exams: \(error), \(error.userInfo)")
            return nil
        }
        
    }
    
    // This method returns true if there is at least one exam for the subject given that is not done yet.
    // It returns false if all exams for the subject given are already done.
    func existsPendingExam(forSubject subject: Subject) -> Bool {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Exam")
        let predicate = NSPredicate(format: "done = %@ AND relSubject = %@", NSNumber(value: false), subject)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        var exams = [Exam]()
        
        do {
            exams = try context.fetch(request) as! [Exam]
            if exams.count > 0 {
                return true
            } else {
                return false
            }
        } catch let error as NSError {
            print ("Could not fetch Exams: \(error), \(error.userInfo)")
            return false
        }
    }
    
    // This method returns exam for given date and subject. If there is no exam for parameters given it returns nil.
    func fetchExam(forDate examDate: Date, andSubject subject: Subject) -> Exam? {
        var exam: Exam? = nil
        if let results = CoreDataManager.sharedInstance.fetchExams(forDate: examDate, andSubject: subject, andDone: nil, orderByDateAcs: nil, orderBySubjectAsc: nil, firstOrderByDate: nil) {
            if results.count > 0 {
                exam = results[0]
            }
        }
        return exam
    }
    
    // This method returns exam with the latest exam date for the subject given.
    func fetchLastExam(forSubject subject: Subject) -> Exam? {
        var exam: Exam? = nil
        if let results = CoreDataManager.sharedInstance.fetchExams(forDate: nil, andSubject: subject, andDone: nil, orderByDateAcs: false, orderBySubjectAsc: nil, firstOrderByDate: nil) {
            if results.count > 0 {
                exam = results[0]
            }
        }
        return exam
    }
    
    // This method returns max sequence number in the database table Information
    func fetchInfoMaxSeqNo() -> Int? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Information")
        
        do {
            let results = try context.fetch(request) as! [Information]
            if results.count > 0 {
                return Int(results.sorted(by: {$0.seqNo > $1.seqNo})[0].seqNo)
            } else {
                return nil
            }
        } catch let error as NSError {
            print ("Could not fetch Information: \(error), \(error.userInfo)")
            return nil
        }
    }
    
    // This method saves (inserts) information with given parameters
    func saveInfo(seqNo: Int64, entryDate: Date, information: String, done: Bool){
        let context = persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Information", in: context)
        let info = NSManagedObject(entity: entityDescription!, insertInto: context) as! Information
        info.seqNo = seqNo
        info.entryDate = (entryDate as NSDate)
        info.information = information
        info.done = done
        saveContext()
    }
    
    // This method returns the array of information based on the parameters provided.
    // It returns all information:
    // - entered on the date given if forDate parameter is given
    // - which are read if andDone is true or which are not read yet if andDone is false - if parameter andDone is given
    // Information in returned array are ordered by:
    // - entry date ascending if orderByDateAsc is true or entry date descending if orderByDateAsc is false - if orderByDateAsc is given
    func fetchInfo(forDate date: Date?, andDone done: Bool?, orderByDateAcs: Bool?) -> [Information]? {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Information")
        var subpredicates = [NSPredicate(format: "1 = 1")]
        var sortDescriptors = [NSSortDescriptor]()
        
        if date != nil {
            subpredicates.append(NSPredicate(format: "entryDate = %@", date! as NSDate))
        }
        
        if done != nil {
            subpredicates.append(NSPredicate(format: "done = %@", NSNumber(booleanLiteral: done!)))
        }
        
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: subpredicates)
        
        request.predicate = andPredicate
        
        request.returnsObjectsAsFaults = false
        
        if let orderByDateAcsending = orderByDateAcs {
            if orderByDateAcsending {
                sortDescriptors.append(NSSortDescriptor(key: "entryDate", ascending: true))
            } else {
                sortDescriptors.append(NSSortDescriptor(key: "entryDate", ascending: false))
            }
        }
        
        if sortDescriptors.count > 0 {
            request.sortDescriptors = sortDescriptors
        }
        
        do {
            let info = try context.fetch(request) as! [Information]
            //print (info)
            return info
        } catch let error as NSError {
            print ("Could not fetch Information: \(error), \(error.userInfo)")
            return nil
        }
        
    }
    
    // This method returns information for given date. If there is no information for parameter given it returns nil.
    func fetchInformation(forDate entryDate: Date) -> Information? {
        var info: Information? = nil
        if let results = CoreDataManager.sharedInstance.fetchInfo(forDate: entryDate, andDone: nil, orderByDateAcs: nil) {
            if results.count > 0 {
                info = results[0]
            }
        }
        return info
    }
    
    // This method returns information with the latest entry date.
    func fetchLastInformation() -> Information? {
        var info: Information? = nil
        
        if let results = CoreDataManager.sharedInstance.fetchInfo(forDate: nil, andDone: nil, orderByDateAcs: false) {
            if results.count > 0 {
                info = results[0]
            }
        }
        return info
    }
    
    // This method returns true if there is at least one timetable item for the subject given.
    // If there is no timetable item for the subject given, it returns false.
    // This method is used when end user wants to delete subject or change subject's name.
    func existsTimetableItemFor(subject: Subject) -> Bool {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let predicate = NSPredicate(format: "relSubject = %@", subject)
        request.predicate = predicate
        do {
            let results = try context.fetch(request) as! [Item]
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch let error as NSError {
            print ("Could not fetch Timetable items: \(error), \(error.userInfo)")
            return false
        }
    }
    
    // This method returns true if there is at least one homework for the subject given.
    // If there is no homework for the subject given, it returns false.
    // This method is used when end user wants to delete subject or change subject's name.
    func existsHomeworkFor(subject: Subject) -> Bool {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Homework")
        let predicate = NSPredicate(format: "relSubject = %@", subject)
        request.predicate = predicate
        do {
            let results = try context.fetch(request) as! [Homework]
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch let error as NSError {
            print ("Could not fetch Homework: \(error), \(error.userInfo)")
            return false
        }
    }
    
    // This method returns true if there is at least one exam for the subject given.
    // If there is no exam for the subject given, it returns false.
    // This method is used when end user wants to delete subject or change subject's name.
    func existsExamFor(subject: Subject) -> Bool {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Exam")
        let predicate = NSPredicate(format: "relSubject = %@", subject)
        request.predicate = predicate
        do {
            let results = try context.fetch(request) as! [Exam]
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch let error as NSError {
            print ("Could not fetch Exams: \(error), \(error.userInfo)")
            return false
        }
    }
    
}

//
//  Subject+CoreDataProperties.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//
//

import Foundation
import CoreData


extension Subject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subject> {
        return NSFetchRequest<Subject>(entityName: "Subject")
    }

    @NSManaged public var name: String?
    @NSManaged public var seqNo: Int64
    @NSManaged public var relExams: NSSet?
    @NSManaged public var relHomeworks: NSSet?
    @NSManaged public var relItems: NSSet?

}

// MARK: Generated accessors for relExams
extension Subject {

    @objc(addRelExamsObject:)
    @NSManaged public func addToRelExams(_ value: Exam)

    @objc(removeRelExamsObject:)
    @NSManaged public func removeFromRelExams(_ value: Exam)

    @objc(addRelExams:)
    @NSManaged public func addToRelExams(_ values: NSSet)

    @objc(removeRelExams:)
    @NSManaged public func removeFromRelExams(_ values: NSSet)

}

// MARK: Generated accessors for relHomeworks
extension Subject {

    @objc(addRelHomeworksObject:)
    @NSManaged public func addToRelHomeworks(_ value: Homework)

    @objc(removeRelHomeworksObject:)
    @NSManaged public func removeFromRelHomeworks(_ value: Homework)

    @objc(addRelHomeworks:)
    @NSManaged public func addToRelHomeworks(_ values: NSSet)

    @objc(removeRelHomeworks:)
    @NSManaged public func removeFromRelHomeworks(_ values: NSSet)

}

// MARK: Generated accessors for relItems
extension Subject {

    @objc(addRelItemsObject:)
    @NSManaged public func addToRelItems(_ value: Item)

    @objc(removeRelItemsObject:)
    @NSManaged public func removeFromRelItems(_ value: Item)

    @objc(addRelItems:)
    @NSManaged public func addToRelItems(_ values: NSSet)

    @objc(removeRelItems:)
    @NSManaged public func removeFromRelItems(_ values: NSSet)

}

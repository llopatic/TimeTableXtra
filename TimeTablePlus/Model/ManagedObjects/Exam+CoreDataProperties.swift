//
//  Exam+CoreDataProperties.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//
//

import Foundation
import CoreData


extension Exam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exam> {
        return NSFetchRequest<Exam>(entityName: "Exam")
    }

    @NSManaged public var done: Bool
    @NSManaged public var examDate: NSDate?
    @NSManaged public var examDesc: String?
    @NSManaged public var seqNo: Int64
    @NSManaged public var relSubject: Subject?

}

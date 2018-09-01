//
//  Homework+CoreDataProperties.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//
//

import Foundation
import CoreData


extension Homework {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Homework> {
        return NSFetchRequest<Homework>(entityName: "Homework")
    }

    @NSManaged public var done: Bool
    @NSManaged public var entryDate: NSDate?
    @NSManaged public var hwDesc: String?
    @NSManaged public var seqNo: Int64
    @NSManaged public var relSubject: Subject?

}

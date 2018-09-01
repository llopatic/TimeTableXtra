//
//  Item+CoreDataProperties.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var from: String?
    @NSManaged public var intFrom: Int64
    @NSManaged public var intTo: Int64
    @NSManaged public var to: String?
    @NSManaged public var relDay: Day?
    @NSManaged public var relSubject: Subject?
    @NSManaged public var relTimetable: Timetable?

}

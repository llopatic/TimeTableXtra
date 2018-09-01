//
//  Day+CoreDataProperties.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//
//

import Foundation
import CoreData


extension Day {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Day> {
        return NSFetchRequest<Day>(entityName: "Day")
    }

    @NSManaged public var name: String?
    @NSManaged public var seqNo: Int64
    @NSManaged public var relItems: NSSet?

}

// MARK: Generated accessors for relItems
extension Day {

    @objc(addRelItemsObject:)
    @NSManaged public func addToRelItems(_ value: Item)

    @objc(removeRelItemsObject:)
    @NSManaged public func removeFromRelItems(_ value: Item)

    @objc(addRelItems:)
    @NSManaged public func addToRelItems(_ values: NSSet)

    @objc(removeRelItems:)
    @NSManaged public func removeFromRelItems(_ values: NSSet)

}

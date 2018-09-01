//
//  Notifications+CoreDataProperties.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 22/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//
//

import Foundation
import CoreData


extension Notifications {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notifications> {
        return NSFetchRequest<Notifications>(entityName: "Notifications")
    }

    @NSManaged public var done: Bool
    @NSManaged public var entryDate: NSDate?
    @NSManaged public var notification: String?
    @NSManaged public var seqNo: Int64

}

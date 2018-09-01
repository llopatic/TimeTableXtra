//
//  Information+CoreDataProperties.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//
//

import Foundation
import CoreData


extension Information {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Information> {
        return NSFetchRequest<Information>(entityName: "Information")
    }

    @NSManaged public var done: Bool
    @NSManaged public var entryDate: NSDate?
    @NSManaged public var information: String?
    @NSManaged public var seqNo: Int64

}

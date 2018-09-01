//
//  FirstRunCompleted+CoreDataProperties.swift
//  TimeTablePlus
//
//  Created by Leonard Lopatic on 23/01/2018.
//  Copyright © 2018 Leonard Lopatic. All rights reserved.
//
//

import Foundation
import CoreData


extension FirstRunCompleted {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FirstRunCompleted> {
        return NSFetchRequest<FirstRunCompleted>(entityName: "FirstRunCompleted")
    }

    @NSManaged public var firstRunCompleted: Bool

}

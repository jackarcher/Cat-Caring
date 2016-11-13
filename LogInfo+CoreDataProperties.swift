//
//  LogInfo+CoreDataProperties.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 9/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import Foundation
import CoreData


extension LogInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogInfo> {
        return NSFetchRequest<LogInfo>(entityName: "LogInfo");
    }

    @NSManaged public var id: String?
    @NSManaged public var pwd: String?
    @NSManaged public var cookie: String?

}

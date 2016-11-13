//
//  DetectionArea+CoreDataProperties.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 13/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import Foundation
import CoreData


extension DetectionArea {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DetectionArea> {
        return NSFetchRequest<DetectionArea>(entityName: "DetectionArea");
    }

    @NSManaged public var id: Int16
    @NSManaged public var y: Float
    @NSManaged public var x: Float
    @NSManaged public var w: Float
    @NSManaged public var h: Float

}

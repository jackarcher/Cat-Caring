//
//  Activity.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 14/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

class Activity: NSObject {
    var image:UIImage?
    var timestamp: NSDate?
    
    init(image:UIImage, on time:NSDate){
        self.image = image
        self.timestamp = time
    }
}

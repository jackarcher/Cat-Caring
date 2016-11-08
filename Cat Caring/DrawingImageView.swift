//
//  DrawingImageView.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 7/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

class DrawingImageView: UIView {

    var imageview:UIImageView
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        setNeedsDisplay()
        let myrect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let newrect = self.imageview.convert(myrect, from: self)
        
        print("orgian\(newrect.origin)")
        
    }
    
}

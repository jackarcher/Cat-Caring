//
//  ActivityLogTableViewCell.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 21/10/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

class ActivityLogTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setTime(dt:NSDate){
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "AEDT")
        df.dateFormat = "MMM-dd HH:mm"
        lblTime.text = df.string(from: dt as Date)
        
    }
}

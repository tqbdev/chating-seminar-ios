//
//  TableViewCell.swift
//  chating-seminar-ios
//
//  Created by An Nguyen on 4/22/18.
//  Copyright © 2018 Tran Quoc Bao. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var EmailText:UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

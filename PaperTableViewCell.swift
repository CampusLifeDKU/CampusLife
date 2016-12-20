//
//  PaperTableViewCell.swift
//  CampusLife
//
//  Created by Daesub Kim on 2016. 12. 6..
//  Copyright © 2016년 DaesubKim. All rights reserved.
//

import UIKit

class PaperTableViewCell: UITableViewCell {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

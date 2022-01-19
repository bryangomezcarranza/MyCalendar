//
//  TitleOfEventCell.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/26/21.
//

import UIKit

class EventInfoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .boldSystemFont(ofSize: 20)
        }
       
    }
    
    @IBOutlet weak var dueDateLabel: UILabel! {
        didSet {
            dueDateLabel.adjustsFontSizeToFitWidth = true
            dueDateLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.adjustsFontSizeToFitWidth = true
            addressLabel.textColor = UIColor.orange
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

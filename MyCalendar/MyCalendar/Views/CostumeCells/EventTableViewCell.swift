//
//  EventTableViewCell.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: - Properties
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func updateViews() {
        guard let event = event else {
            // in the case that event does not exist, clear the text fields
            titleLabel.text = ""
            dateLabel.text = ""
            return
        }
        titleLabel.text = event.name
        dateLabel.text = event.dueDate.formatDate()
    }
}

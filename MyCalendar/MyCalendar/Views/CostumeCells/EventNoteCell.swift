//
//  EventAddressCell.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/26/21.
//

import UIKit

class EventNoteCell: UITableViewCell {

    @IBOutlet weak var noteLabel: UILabel! {
        didSet {
            noteLabel.numberOfLines = 0
            noteLabel.adjustsFontSizeToFitWidth = true
            noteLabel.font = .systemFont(ofSize: 18)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

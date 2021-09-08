//
//  EventTableViewCell.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import UIKit

protocol EventTableViewCellDelegate: AnyObject {
    func eventCellButtonTapped(_ sender: EventTableViewCell)
}

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itsCompletedButton: UIButton!
    
    //MARK: - Properties
    weak var delegate: EventTableViewCellDelegate?
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    //MARK: - Actions
    @IBAction func hasBeenCompletedButtonTapped(_ sender: Any) {
        delegate?.eventCellButtonTapped(self)
        print("buttonRapped")
            
    }
    
    func updateViews() {
        guard let event = event else {
            // in the case that event does not exist, clear the text fields
            titleLabel.text = ""
            dateLabel.text = ""
            return
        }
        titleLabel.text = event.name
        dateLabel.text = "Due: \(event.dueDate.formatDate())"
       
        
        let image = event.isCompleted ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        itsCompletedButton.setImage(image, for: .normal)
    }
}

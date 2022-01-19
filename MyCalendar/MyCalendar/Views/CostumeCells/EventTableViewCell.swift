//
//  EventTableViewCell.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import UIKit
import CloudKit
import MapKit

protocol EventTableViewCellDelegate: AnyObject {
    func eventCellButtonTapped(_ record: Event, _ cell: EventTableViewCell)
}

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itsCompletedButton: UIButton!
    
    //MARK: - Properties
    
    private var isChecked: Bool = false
    private let uncheckedIcon = UIImage(systemName: "square")!
    private let checkedIcon = UIImage(systemName: "checkmark.square")!
    
    weak var delegate: EventTableViewCellDelegate?
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Actions
    
    @IBAction func hasBeenCompletedButtonTapped(_ sender: Any) {
        guard let event = event else { return }
        
        isChecked.toggle()
      
        
        if isChecked  {
            event.isCompleted = 1
        } else {
            event.isCompleted = 0
        }
        
        itsCompletedButton.setBackgroundImage(isChecked ? checkedIcon : uncheckedIcon, for: .normal)
        
        delegate?.eventCellButtonTapped(event, self)
    }
    
    func updateViews() {

        guard let event = event else {
            titleLabel.text = ""
            dateLabel.text = ""
            return
        }
        
        titleLabel.text = event.name
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        dateLabel.text = "Starts at: \(event.dueDate.formatDate())"
        dateLabel.layer.opacity = 0.7
        
        if (event.isCompleted == 0) {
            self.isChecked = false
            itsCompletedButton.setBackgroundImage(uncheckedIcon, for: .normal)
        } else {
            self.isChecked = true
            itsCompletedButton.setBackgroundImage(checkedIcon, for: .normal)
        }
    }
}

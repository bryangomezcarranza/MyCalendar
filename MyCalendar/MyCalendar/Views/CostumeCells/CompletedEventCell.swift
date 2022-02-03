//
//  CompletedEventCell.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 1/20/22.
//

import UIKit

protocol CompletedEventCellDelegate: AnyObject {
    func trashButtonPressed(cell: UITableViewCell)
}

class CompletedEventCell: UITableViewCell {
    
    @IBOutlet weak var nameOfEvent: UILabel!
    @IBOutlet weak var dateOfEvent: UILabel!
    
    weak var delegate: CompletedEventCellDelegate?
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
       guard let event = event else { return }
        delegate?.trashButtonPressed(cell: self)
    }
    
    func updateViews() {
        guard let event = event else {
            nameOfEvent.text = ""
            dateOfEvent.text = ""
            return
        }
    
        nameOfEvent.text = event.name
        nameOfEvent.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        dateOfEvent.text = "Completed: \(event.dueDate.formatDueDate())"
        dateOfEvent.layer.opacity = 0.7
        dateOfEvent.textColor = .systemRed
        dateOfEvent.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.light)
        
        
    }
}

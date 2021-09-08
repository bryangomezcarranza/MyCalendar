//
//  DueDateTableViewCell.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/5/21.
//

import UIKit

class DueDateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dueDatetextField: UITextField!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let event = event else { return }
        dueDatetextField.text = event.dueDate.formatDate()
    }
}

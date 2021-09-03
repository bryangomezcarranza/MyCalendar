//
//  EventDetailViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    //MARK: - Properties
    var event: Event?
    var date: Date?
    
    //MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty, let note = noteTextField.text, !note.isEmpty  else { return }
        let date = dueDatePicker.date
        
        if let event = event {
            event.name = title
            event.note = note
            event.dueDate = date
            EventController.shared.updateEvent(event) { result in
                switch result {
                
                case .success(_):
                    print("Succesfully updated")
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        } else  {
            EventController.shared.createEvent(with: title, note: note, dueDate: date) { result in
                switch result {
                
                case .success( let event):
                    guard let event = event else { return }
                    EventController.shared.events.insert(event, at: 0)
                    self.updateViews()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    @IBAction func dateOfEventPickerChanged(_ sender: Any) {
        guard let date = date else { return }
        dueDatePicker.date = date
    }
    //MARK: - Helper Methods
    func updateViews() {
        guard let event = event else { return }
        titleTextField.text = event.name
        noteTextField.text = event.note
        dueDatePicker.date = event.dueDate
    }
}

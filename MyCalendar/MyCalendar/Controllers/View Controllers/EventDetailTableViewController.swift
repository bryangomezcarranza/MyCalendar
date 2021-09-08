//
//  EventDetailTableViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/3/21.
//

import UIKit

class EventDetailTableViewController: UITableViewController {

    //MARK: - Properties
    var event: Event?
    var date: Date?
    
    //MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()

        
    }
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty, let note = noteTextField.text, !note.isEmpty, let location = locationTextField.text  else { return }
        let date = dueDatePicker.date
        
        if let event = event {
            event.name = title
            event.note = note
            event.dueDate = date
            event.location = location

            EventController.shared.updateEvent(event) { result in
                switch result {
                
                case .success(_):
                    print("Succesfully updated")
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        } else  {
            EventController.shared.createEvent(with: title, note: note, dueDate: date, location: location) { result in
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
    @IBAction func dueDatePickerChanged(_ sender: Any) {
        guard let date = date else { return }
        dueDatePicker.date = date
    }
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let event = event else { return }
        titleTextField.text = event.name
        noteTextField.text = event.note
        dueDatePicker.date = event.dueDate
        locationTextField.text = event.location
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLocation" {
            guard let vc = segue.destination as? LocationViewController else { return }
            vc.delegate = self 
        }
    }
}



extension EventDetailTableViewController: LocationPinSavedDelegate {
    func savedLocationButtonTapped(location: String) {
        locationTextField.text = location
    }
}



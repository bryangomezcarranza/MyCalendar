//
//  EventDetailTableViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/3/21.
//

import UIKit
import MapKit


class EventDetailTableViewController: UITableViewController {

    //MARK: - Properties
    var event: Event?
    var reminderDate: Date?
    
    let datePicker = UIDatePicker()
    
    
    //MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        createDatePickerView()
        
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        navigationController?.navigationBar.standardAppearance =  appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        reminderDatePicker.preferredDatePickerStyle = .compact
        reminderDatePicker.inputView?.sizeToFit()
        
//        let screenWidth = self.view.frame.width
//        let screenHeight = self.view.frame.height
//        reminderDatePicker.frame = CGRect(x: 0, y: screenHeight - 216 - 44, width: screenWidth, height: 216)
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty, let note = noteTextField.text, !note.isEmpty, let dueDate = dueDateTextField.text, !dueDate.isEmpty, let location = locationTextField.text  else { return }
    
        let reminder = reminderDatePicker.date
        
        if let event = event {
            event.name = title
            event.note = note
            event.dueDate = dueDate.toDate()
            event.location = location
            event.reminderDate = reminder

            EventController.shared.updateEvent(event) { result in
                switch result {
                
                case .success(_):
                    print("Succesfully updated")
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        } else  {
            EventController.shared.createEvent(with: title, note: note, dueDate: dueDate.toDate(), reminderDate: reminder, location: location) { result in
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

    
    @IBAction func reminderDatePicker(_ sender: Any) {
        guard let date = reminderDate else { return }
        reminderDatePicker.date = date
    }
    
    //MARK: - Helper Methods
    
    func createToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        // done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)

        return toolbar
    }
    func createDatePickerView() {
        datePicker.preferredDatePickerStyle = .wheels
        dueDateTextField.inputView = datePicker
        dueDateTextField.inputAccessoryView = createToolBar()
    }

   @objc func donePressed() {
       self.dueDateTextField.text = datePicker.date.formatDueDate()
        self.view.endEditing(true)
    }
    
    func updateViews() {
        guard let event = event else { return }
        titleTextField.text = event.name
        noteTextField.text = event.note
        dueDateTextField.text = event.dueDate.formatDueDate()
        locationTextField.text = event.location
        reminderDatePicker.date = event.reminderDate
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLocationView" {
            guard let destinationVC = segue.destination as? LocationTableViewController else { return }
            destinationVC.delegate = self
        }
    }
}

//MARK: -
extension EventDetailTableViewController: UpdateLocationProtocol {
    func updateLocation(with location: MKLocalSearchCompletion) {
        locationTextField.text = location.subtitle
    }  
}

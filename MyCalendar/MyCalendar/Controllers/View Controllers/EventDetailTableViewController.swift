//
//  EventDetailTableViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/3/21.
//

import UIKit
import MapKit

class EventDetailTableViewController: UITableViewController, UITextViewDelegate {
    
    //MARK: - Properties
    
    var event: Event?
    var reminderDate: Date?
    let datePicker = UIDatePicker()
    
    //MARK: - Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
    
        updateViews()
        createDatePickerView()
        navBarAppearance()
        noteTextView.delegate = self
        noteTextView.placeholder = "Notes.."
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTabBar()
    }
    
    //MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let title = titleTextField.text, !title.isEmpty, let note = noteTextView.text, let dueDate = dueDateTextField.text, !dueDate.isEmpty, let location = locationTextField.text  else { return }
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
            
            EventController.shared.createEvent(with: title, note: note, dueDate: dueDate.toDate(), reminderDate: reminder, location: location) { [weak self] result in
                guard let self = self else { return }
                
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
    
    //MARK: - UI
    private func navBarAppearance() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "navbar-tabbar")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
    //MARK: - Helper Methods
    
    private func configureTabBar() {
        tabBarController?.tabBar.isHidden = true
    }
    
    private func createToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        return toolbar
    }
    
    private func createDatePickerView() {
        
        datePicker.preferredDatePickerStyle = .wheels
        dueDateTextField.inputView = datePicker
        dueDateTextField.inputAccessoryView = createToolBar()
    }
    
    @objc private func donePressed() {
        
        self.dueDateTextField.text = datePicker.date.formatDueDate()
        self.view.endEditing(true)
    }
    
    private func updateViews() {
        
        guard let event = event else { return }
        titleTextField.text = event.name
        noteTextView.text = event.note
        dueDateTextField.text = event.dueDate.formatDueDate()
        locationTextField.text = event.location
        reminderDatePicker.date = event.reminderDate
        
        locationTextField.adjustsFontSizeToFitWidth = true
        locationTextField.minimumFontSize = 14
        
        reminderDatePicker.preferredDatePickerStyle = .compact
        reminderDatePicker.inputView?.sizeToFit()
    }
    //MARK: - Segue navigation
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

//MARK: - UITextView Delegate for Placeholder
extension UITextView: UITextViewDelegate {
    
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
                
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.placeholderText
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}


//
//  CompletedEventsViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 1/19/22.
//

import UIKit

class CompletedEventsViewController: UIViewController {
    
    var event: [Event] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func clearAllEventsClicked(_ sender: Any) {
 
    }
    
    func fetchData() {
        EventController.shared.fetchEvent { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let completedEvent):
                let events = completedEvent.filter({$0.isCompleted == 1 })
                
                let sortedEvents = events.sorted(by: {$0.dueDate > $1.dueDate})
                EventController.shared.events = sortedEvents
                DispatchQueue.main.async {
                    self.event.append(contentsOf: sortedEvents)
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }

    }
}

extension CompletedEventsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        event.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "completedEvent", for: indexPath) as? CompletedEventCell  else { return UITableViewCell() }
        let event = event[indexPath.row]
        cell.event = event
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
}

extension CompletedEventsViewController: CompletedEventCellDelegate {
    func trashButtonPressed(cell: UITableViewCell) {
       guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let index = self.event[indexPath.row]
        EventController.shared.delete(index) { result in
            switch result {
            case .success(let event):
                if event == true {
                    DispatchQueue.main.async {
                        self.event.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

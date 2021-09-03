//
//  ViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/30/21.
//

import UIKit

class EventsViewController: UIViewController {
    //MARK: - Outlets

    @IBOutlet weak var monthLabelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    
    // storage
    private var eventsByDay: [Date: [Event]] = [:]
    private var sectionIndex: [Date] = []
    
    
//MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        searchBar()
        navigationBar()
    
 
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorColor = UIColor.systemBlue
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViews()
        tableView.reloadData()
    }
    //MARK: - Action

    
    //MARK: - Helpers

    
    func searchBar() {
        navigationItem.searchController = searchController
    }
    func navigationBar() {
        navigationController?.navigationBar.backgroundColor = UIColor.white
    }
    
    func loadData() {
        EventController.shared.fetchEvent { result in
            switch result {
            case .success(let event):
                EventController.shared.events = event
                self.updateViews()
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    func updateViews() {
        DispatchQueue.main.async {
            self.eventsByDay = [:]
            for event in EventController.shared.events {
                let date = Calendar.current.startOfDay(for: event.dueDate)
                var events = self.eventsByDay[date] ?? []
                events.append(event)
                self.eventsByDay[date] = events
            }
            self.sectionIndex = self.eventsByDay.keys.sorted()
            self.tableView.reloadData()
        }
    }
}
//MARK: - tableview Delegate & DataSource
extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionIndex.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sectionIndex.indices.contains(section) else { return nil }
        
        // return the header view here
        let day = sectionIndex[section]
        let view = UIView()
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 100)
        
        let label = UILabel()
        label.text = day.formatDay()
        label.font = UIFont(name: "PingFangSC-Thin", size: 17.0)
        label.frame = CGRect(x: 32, y: 0, width: 100, height: 35)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard sectionIndex.indices.contains(section) else { return 0 }
        let day = sectionIndex[section]
        return eventsByDay[day]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard sectionIndex.indices.contains(indexPath.section) else { return UITableViewCell() }
//        let day = sectionIndex[indexPath.section]
//
//        guard let events = eventsByDay[day], events.indices.contains(indexPath.row) else { return UITableViewCell() }
//        let event = events[indexPath.row]
        
        let event = eventsByDay[sectionIndex[indexPath.section]]![indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        cell.event = event
        
        // CostumeSeperator
        cell.separatorInset.left = 32
        
        return cell
      
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            let eventToDelete = EventController.shared.events[indexPath.row]
//            let event = eventsByDay[sectionIndex[indexPath.section]]![indexPath.row]
            
            guard let index = EventController.shared.events.firstIndex(of: eventToDelete) else { return }
            
            EventController.shared.delete(eventToDelete) { result in
                switch result {
                
                case .success( let bool ):
                    if bool == true {
                        EventController.shared.events.remove(at: index)
                        DispatchQueue.main.async {
                            // Delete row that was selected.
                            self.sectionIndex.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
     //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow, let destinationVC = segue.destination as? EventDetailViewController else { return }
            let event = eventsByDay[sectionIndex[indexPath.section]]![indexPath.row]
            destinationVC.event = event
        }
    }
}



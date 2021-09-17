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
    @IBOutlet weak var noEventsView: UIView!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var newEventButton: UIButton!
    
    //MARK: - Properties
    
    var refresh = UIRefreshControl()
    
    //Search Bar
    var searchedEvents = [Date: [Event]]()
    var searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    
    // storage
    private var eventsByDay: [Date: [Event]] = [:]
    private var sectionIndex: [Date] = []
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        searchBarSetUp()
        navigationBar()
        refreshSetUp()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.systemBlue
        tableView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViews()
        //self.tableView.reloadData()
    }
    
    //MARK: - Helpers
    func refreshSetUp() {
        refresh.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    func searchBarSetUp() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search your events"
        searchController.searchBar.returnKeyType = .go
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func navigationBar() {
        navigationController?.navigationBar.backgroundColor = UIColor.white
    }
    
    @objc func loadData() {
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
                let date = Calendar.current.startOfDay(for: event.dueDate)// makes todays date the due date.
                var events = self.eventsByDay[date] ?? []
                events.append(event)
                self.eventsByDay[date] = events
            }
            self.sectionIndex = self.eventsByDay.keys.sorted()
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    func filterContent(searchText: String) {
        if searchText.count > 0 {
            //searchedEvents = eventsByDay.filter(<#T##isIncluded: (Dictionary<Date, [Event]>.Element) throws -> Bool##(Dictionary<Date, [Event]>.Element) throws -> Bool#>)
            
        }
        self.tableView.reloadData()
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
        label.font = UIFont(name: "PingFangSC-Thin", size: 15.0)
        label.frame = CGRect(x: 32, y: 0, width: 300, height: 35)
        view.addSubview(label)
        
        // Color Sectioning based on Todays Date.
        
        if day.formatDay() == Date().formatDay() {
            label.textColor = UIColor.systemBlue
            label.text = "Today, \(day.formatDay())"
        } else if day.formatDay() < Date().formatDay() {
            label.textColor = UIColor.red
            label.text = "Past Due - \(day.formatDay())"
        } else {
            label.textColor = UIColor.black
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard sectionIndex.indices.contains(section) else { return 0 }
        let day = sectionIndex[section]
        
        // No Events View
        if eventsByDay[day]?.count == 0 {
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
        }
        return  isFiltering ? searchedEvents.count : eventsByDay[day]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = [indexPath.row]
        
        guard sectionIndex.indices.contains(indexPath.section) else { return UITableViewCell() }
        let day = sectionIndex[indexPath.section]
        
        guard let events = eventsByDay[day], events.indices.contains(indexPath.row) else { return UITableViewCell() }
        let event = events[indexPath.row]
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        cell.event = event
        cell.delegate = self
        
        // Costume Seperator
    
        if (row.count == 1 && row.count < 1) {
            cell.layer.borderColor = UIColor.systemBlue.cgColor
            cell.layer.borderWidth = 0.5
        } else if (row.count == 1 && row.count > 1) {
            cell.separatorInset.left = 32
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let eventToDelete = eventsByDay[sectionIndex[indexPath.section]]![indexPath.row]
            
            guard let index = EventController.shared.events.firstIndex(of: eventToDelete) else  { return }
            
            EventController.shared.delete(eventToDelete) { result in
                switch result {
                
                case .success( let bool ):
                    if bool == true {
                        EventController.shared.events.remove(at: index)
                        DispatchQueue.main.async {
                            // Delete row that was selected.
                            self.eventsByDay[eventToDelete.dueDate]?.remove(at: indexPath.row)
                            self.updateViews()
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
            guard let indexPath = tableView.indexPathForSelectedRow, let destinationVC = segue.destination as? EventDetailTableViewController else { return }
            let event = eventsByDay[sectionIndex[indexPath.section]]![indexPath.row]
            destinationVC.event = event
        }
    }
}
//MARK: - isCompletedDelegate Extension
extension EventsViewController: EventTableViewCellDelegate {
    func eventCellButtonTapped(_ sender: EventTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        let event = eventsByDay[sectionIndex[indexPath.section]]![indexPath.row]
        event.isCompleted.toggle()
        tableView.reloadData()
    } 
}

//MARK: - SearchBar Delegate & ResultUpdating

extension EventsViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContent(searchText: searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}




//
//  ViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/30/21.
//

import UIKit
import CloudKit

class EventsViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var monthLabelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsView: UIView!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var newEventButton: UIButton!
    
    //MARK: - Properties
    
    // removes ovserver
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var refresh = UIRefreshControl()
    let notificcationScheduler = NotificationScheduler()
    
    //MARK: - Search Bar Properties
    
    var event: Event?
    
    var searchedEvents = [Date: [Event]]()
    var searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //MARK: - Computed Properties
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    var dataSource: [Date: [Event]] { //
        if isSearchBarEmpty {
            return  eventsByDay // all of them
        } else {
            return searchedEvents // filtered stuff
        }
    }
    
    var dataSourceIndex: [Date] {
        if isSearchBarEmpty {
            return sectionIndex
        } else {
            return searchedEvents.keys.sorted()
        }
    }
    
    //MARK: - Storage for Sectioning
    
    private var eventsByDay: [Date: [Event]] = [:] {
        didSet {
            if eventsByDay.count > 0 {
                self.tableView.isHidden = false
            } else {
                self.tableView.isHidden = true
            }
        }
    }
    
    private var sectionIndex: [Date] = []
    
    //MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        searchBarSetUp()
        navigationBarColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name(UIApplication.didBecomeActiveNotification.rawValue), object: nil)
        startObserving(&UserInterfaceStyleManager.shared)
        refreshSetUp()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViews()
    }
    
    //MARK: - UI
    
    private func navigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "navbar-tabbar")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance =
        navigationController?.navigationBar.standardAppearance
    }
    
    private func searchBarSetUp() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for events"
        searchController.searchBar.returnKeyType = .go
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    //MARK: - Helpers
    
    private func refreshSetUp() {
        refresh.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    @objc private func loadData() {
        
        EventController.shared.fetchEvent { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let event):
                // Goes through each Event and if its equal to 0 it will fetch it.
                let events = event.filter({$0.isCompleted == 0 })
                EventController.shared.events = events
                self.updateViews()
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    private func updateViews() {
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
    
    private func filterContent(searchText: String) {
        
        searchedEvents =  [:]
        
        for (key, value) in eventsByDay {
            let filtered = value.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            
            if !filtered.isEmpty { // checks to see if there is anything left over. If not empy, we will display.
                searchedEvents[key] = filtered
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func setupViews() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.systemBlue
        //self.tableView.isHidden = true
        
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = CGFloat(0)
            UITableView.appearance().sectionFooterHeight = CGFloat(0)
        } else {
            // Fallback on earlier versions
        }
    }
}

//MARK: - tableview Delegate & DataSource
extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard dataSourceIndex.indices.contains(section) else { return nil }
        
        // return the header view here
        let day = dataSourceIndex[section]
        
        
        let view = UIView()
        view.clipsToBounds = true
        view.frame =  CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0)
        view.backgroundColor = UIColor(named: "tableview-section")
        
        let label = UILabel()
        label.text = day.formatDay()
        label.font = UIFont(name: "PingFangSC-Thin", size: 15.0)
        label.frame = CGRect(x: 32, y: 0, width: tableView.frame.width, height: 32)
        view.addSubview(label)
        
        // Color Sectioning based on Todays Date.
        if day.formatDay() == Date().formatDay() {
            label.textColor = UIColor.systemBlue
            label.text = "Today, \(day.formatDay())"
        } else if day < Date() {
            label.textColor = UIColor(named: "pastDate")
            label.text = "Past Due - \(day.formatDay())"
        } else  {
            label.textColor = UIColor(named: "futureDate")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard dataSourceIndex.indices.contains(section) else { return 0 }
        let day = dataSourceIndex[section]
        
        return dataSource[day]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard dataSourceIndex.indices.contains(indexPath.section) else { return UITableViewCell() }
        let day = dataSourceIndex[indexPath.section]
        
        guard let events = dataSource[day], events.indices.contains(indexPath.row) else { return UITableViewCell() }
        
        let event = events[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        cell.event = event
        cell.delegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let eventToDelete = dataSource[dataSourceIndex[indexPath.section]]![indexPath.row]
            
            guard let index = EventController.shared.events.firstIndex(of: eventToDelete) else  { return }
            
            EventController.shared.delete(eventToDelete) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success( let bool ):
                    if bool == true {
                        EventController.shared.events.remove(at: index)
                        DispatchQueue.main.async {
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
            let event = dataSource[dataSourceIndex[indexPath.section]]![indexPath.row]
            destinationVC.event = event
        } else if segue.identifier == "goToDetails" {
            guard let indexPath = tableView.indexPathForSelectedRow, let destinationVC = segue.destination as? DetailViewController else { return }
            let event = dataSource[dataSourceIndex[indexPath.section]]![indexPath.row]
            destinationVC.event = event
        }
    }
}

//MARK: - isCompletedDelegate Extension

extension EventsViewController: EventTableViewCellDelegate {
    func eventCellButtonTapped(_ record: Event, _ cell: EventTableViewCell) {
        EventController.shared.updateEvent(record) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                DispatchQueue.main.async { [self] in
                    guard let indexPath = self.tableView.indexPath(for: cell) else { return }
                    
                    // If sucess, delete the row that was clicked from the Table View.
                    let event = self.dataSourceIndex[indexPath.section]
                    self.eventsByDay[event]?.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .left)
                    
                    let section = indexPath.section
                    let rows = self.tableView(self.tableView, numberOfRowsInSection: section)
                    
                    // Deletes the section if there is no rows.
                    if rows == 0 {
                        self.tableView.beginUpdates()
                        self.eventsByDay.removeValue(forKey: event)
                        self.tableView.deleteSections([indexPath.section], with: .left)
                        self.tableView.endUpdates()
                    }
                    
                    self.tableView.reloadData()
                    
                    print("Succesfully updated")
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
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





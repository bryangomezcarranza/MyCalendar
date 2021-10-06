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
    let notificcationScheduler = NotificationScheduler()
    
   //MARK: - Search Bar Set Up
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
    private var eventsByDay: [Date: [Event]] = [:]
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
        searchController.searchBar.placeholder = "Search your events"
        searchController.searchBar.returnKeyType = .go
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    //MARK: - Helpers
    private func reloadView() {
        EventController.shared.fetchEvent { result in
            switch result {
            case .success(let event):
                EventController.shared.events = event
                self.updateViews()
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        self.tableView.reloadData()
    }

    private func refreshSetUp() {
        refresh.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    @objc private func loadData() {
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
        self.tableView.isHidden = true
        
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
        
        // No Events View
        if eventsByDay[day]?.count == 0 {
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
        }
        return dataSource[day]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = [indexPath.row]
        
        guard dataSourceIndex.indices.contains(indexPath.section) else { return UITableViewCell() }
        let day = dataSourceIndex[indexPath.section]
        
        guard let events = dataSource[day], events.indices.contains(indexPath.row) else { return UITableViewCell() }
        
        
        let event = events[indexPath.row]
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        cell.event = event
        cell.delegate = self
        
        // Costume Seperator

        if (row.count == 0 && row.count < 0) {
            cell.layer.borderColor = UIColor.systemBlue.cgColor
            cell.layer.borderWidth = 0.5
        } else if (row.count == 0 && row.count > 0) {
            cell.separatorInset.left = 100
        }
        
       
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let eventToDelete = dataSource[dataSourceIndex[indexPath.section]]![indexPath.row]
            
            guard let index = EventController.shared.events.firstIndex(of: eventToDelete) else  { return }
            
            EventController.shared.delete(eventToDelete) { result in
                switch result {
                
                case .success( let bool ):
                    if bool == true {
                        EventController.shared.events.remove(at: index)
                        DispatchQueue.main.async {
                            // Delete row that was selected.
                            //self.eventsByDay[eventToDelete.dueDate]?.remove(at: indexPath.row)
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
    func eventCellButtonTapped(_ sender: EventTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        let event = eventsByDay[sectionIndex[indexPath.section]]![indexPath.row]
        EventController.shared.toggleIsCompleted(event: event)
        
        if event.isCompleted {
            
            guard let index = EventController.shared.events.firstIndex(of: event) else  { return }
            
            EventController.shared.delete(event) { result in
                switch result {
                
                case .success( let bool ):
                    if bool == true {
                        EventController.shared.events.remove(at: index)
                        DispatchQueue.main.async {
                            // Delete row that was selected.
                            //self.eventsByDay[eventToDelete.dueDate]?.remove(at: indexPath.row)
                            self.updateViews()
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
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





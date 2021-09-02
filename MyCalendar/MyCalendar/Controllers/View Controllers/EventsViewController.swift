//
//  ViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/30/21.
//

import UIKit

class EventsViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    var selectedDate = Date()
    var totalSquares = [String]()
    
    // storage
    private var eventsByDay: [Date: [Event]] = [:]
    private var sectionIndex: [Date] = []
    
    
//MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        searchBar()
        navigationBar()
        setMonthView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViews()
    }
    //MARK: - Action
    @IBAction func previousMonth(_ sender: UIButton) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
        
    }
    @IBAction func nextMonth(_ sender: UIButton) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    //MARK: - Helpers
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.width - 2) / 8
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().dayOfMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while (count <= 42) {
            if (count <= startingSpaces || count - startingSpaces > daysInMonth) {
                totalSquares.append("")
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: CalendarHelper().monthString(date: selectedDate) + " " + (CalendarHelper().dayString(date: selectedDate)) + ", " + CalendarHelper().yearString(date: selectedDate), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "PingFangSC-Thin", size: 25.0)!,
                                                                  NSAttributedString.Key.foregroundColor: UIColor.black],
                                                              for: .normal)

        collectionView.reloadData()

    }
    
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
//MARK: - CollectionView Delegate & DataSource
extension EventsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as? CalendarCollectionViewCell else { return UICollectionViewCell() }
        let dateSelected = totalSquares[indexPath.item]
        cell.dayOfMonth.text = dateSelected
        return cell
        
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
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        
        let label = UILabel()
        label.text = formatter.string(from: day)
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard sectionIndex.indices.contains(section) else { return 0 }
        let day = sectionIndex[section]
        return eventsByDay[day]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard sectionIndex.indices.contains(indexPath.section) else { return UITableViewCell() }
        let day = sectionIndex[indexPath.count]
        
        guard let events = eventsByDay[day], events.indices.contains(indexPath.row) else { return UITableViewCell() }
        let event = events[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        cell.event = event
        return cell
    }
    
   
}




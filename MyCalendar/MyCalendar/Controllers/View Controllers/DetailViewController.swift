//
//  DetailViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/26/21.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    //MARK: - IB Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    var event: Event?
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarAppearance()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    //MARK: - UI
    private func navBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "navbar-tabbar")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
    //MARK: - IB Actions
    @IBAction func mapViewTapped(_ sender: UITapGestureRecognizer) {
        coordinates(forAddress: event!.location) { [self] location in
            guard let location = location else { return }
            openMapForPlace(lat: location.latitude, long: location.longitude, placeName: self.event!.location)
            
            view.snapshotView(afterScreenUpdates: true)
        }
    }
    
    //MARK: - Helper Methods
    func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }
    
    public func openMapForPlace(lat:Double = 0, long:Double = 0, placeName:String = "") {
        let latitude: CLLocationDegrees = lat
        let longitude: CLLocationDegrees = long

        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: options)
    }

}
//MARK: - UITableView Delegate & Data Source
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventInfoCell.self), for: indexPath) as! EventInfoCell
            cell.titleLabel.text = event!.name
            cell.dueDateLabel.text = "Event due on \n\(event!.dueDate.formatDueDate())"
            cell.addressLabel.text = event?.location
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventNoteCell.self), for: indexPath) as! EventNoteCell
            cell.noteLabel.text = event!.note
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LocationMapCell.self), for: indexPath) as! LocationMapCell
            
            if event?.location.isEmpty == true {
                print("No Location")
            } else {
                cell.configure(location: event!.location)
            }
            return cell
        default:
            fatalError("failed")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = indexPath.row
        let eventLocation = event?.location
        let eventNote = event?.note
        
        if row == 2 {
            if  eventLocation?.isEmpty == true {
              return 0
            } else  {
             return 200
            }
        } else if row == 0 {
            return 150
        } else if row == 1 {
            if eventNote?.isEmpty == true {
                return 0
            } else {
            return 90
            }
        } else {
            return tableView.rowHeight
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventDetail" {
            guard let destinationVC = segue.destination as? EventDetailTableViewController else { return }
            let event = event
            destinationVC.event = event
            self.tableView.reloadData()
        }
    }
}

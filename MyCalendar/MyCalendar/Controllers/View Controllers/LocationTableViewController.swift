//
//  LocationViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/7/21.
//

import UIKit
import MapKit
import CoreLocation

//MARK: - Protocol for Location
protocol UpdateLocationProtocol: AnyObject {
    func updateLocation(with location: MKLocalSearchCompletion)
}

class LocationTableViewController: UITableViewController {
    
    //MARK: - Private Properties
    private var locationManager = CLLocationManager()
    private var currentPlacemark: CLPlacemark?
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    private var foregroundRestorationObserver: NSObjectProtocol?
    private var searchCompleter: MKLocalSearchCompleter?
    private var completerResults: [MKLocalSearchCompletion]?
    private var completerSearch = false
    private var places: [MKMapItem]?
    private var localSearch: MKLocalSearch?
    
    //MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    weak var delegate: UpdateLocationProtocol?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        startProvidingCompletions()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopProvidingCompletions()
    }
    
    //MARK: - Private Funcs
    private func setupView() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        
        startObserving(&UserInterfaceStyleManager.shared)
        locationManager.delegate = self
    }
    
    private func startProvidingCompletions() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.resultTypes = .pointOfInterest
        //searchCompleter?.region = searchRegion
    }
    
    private func stopProvidingCompletions() {
        searchCompleter = nil
        searchCompleter?.region = boundingRegion
    }
    
    private func searchSuggestions(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        searchLocaly(using: searchRequest)
    }
    
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        searchLocaly(using: searchRequest)
    }
    
    private func searchLocaly(using searchRequest: MKLocalSearch.Request) {
        searchRequest.region = boundingRegion
        searchRequest.resultTypes = .pointOfInterest
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                self.displaySearchError(error)
                return
            }
            self.places = response?.mapItems
            if let updateRegion = response?.boundingRegion {
                self.boundingRegion = updateRegion
            }
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func updatePlacemark(_ placemark: CLPlacemark?, boundingRegion: MKCoordinateRegion) {
        currentPlacemark = placemark
        searchCompleter?.region = boundingRegion
    }
    
    
    private func displayLocationServicesDeniedAlert() {
        let alertController = UIAlertController(title: "Location Authorization",
                                                message: "Need your current location to search for near by places",
                                                preferredStyle: .alert)
        let openSettingsAction = UIAlertAction(title: "Update Settings", style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(openSettingsAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Table delegate & data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerSearch ? completerResults?.count ?? 0 : places?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        
        if completerSearch {
            if let suggestion = completerResults?[indexPath.row] {
                cell.textLabel?.attributedText = highlight(text: suggestion.title, rangeValues: suggestion.titleHighlightRanges)
                cell.detailTextLabel?.attributedText = highlight(text: suggestion.subtitle, rangeValues: suggestion.subtitleHighlightRanges)
            }
        } else {
            let mapItem = places?[indexPath.row]
            cell.textLabel?.text = mapItem?.name
            cell.detailTextLabel?.text = mapItem?.placemark.formattedAddress
            cell.detailTextLabel?.numberOfLines = 0
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let location = completerResults![indexPath.row]
        delegate!.updateLocation(with: location)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func highlight(text: String, rangeValues: [NSValue]) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.backgroundColor: UIColor.yellow]
        let highlightedString = NSMutableAttributedString(string: text)
        
        let ranges = rangeValues.map({ $0.rangeValue })
        
        ranges.forEach { range in
            highlightedString.addAttributes(attributes, range: range)
        }
        return highlightedString
    }
}

//MARK: - UISearchBar Delegate
extension LocationTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        search(for: searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter?.queryFragment = searchText
    }
    
}

//MARK: - CLLocationManager Delegate
extension LocationTableViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            displayLocationServicesDeniedAlert()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemark, error) in
            guard error == nil else { return }
            
            self.currentPlacemark = placemark?.first
            self.boundingRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
            self.updatePlacemark(self.currentPlacemark, boundingRegion: self.boundingRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted:
            print("\nUsers location is restricted")
            
        case .denied:
            print("\nUser denied access to use their location\n")
            
        case .authorizedWhenInUse:
            print("\nuser granted authorizedWhenInUse\n")
            
        case .authorizedAlways:
            print("\nuser selected authorizedAlways\n")
            
        default: break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

//MARK: - MKLocalSearchComplerer Delegate
extension LocationTableViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerSearch = true
        completerResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
}

//MARK: - SearchResultUpdating Delegate
extension LocationTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchCompleter?.queryFragment = searchController.searchBar.text ?? ""
    }
}

//MARK: - Scrollview
extension LocationTableViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.resignFirstResponder()
    }
}



    

    


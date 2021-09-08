//
//  LocationViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/7/21.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationPinSavedDelegate: AnyObject {
    func savedLocationButtonTapped(location: String)
}

class LocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UITextField!
    
    let locationManager = CLLocationManager()
    var regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
    weak var delegate: LocationPinSavedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
    }
    @IBAction func doneButtonTapped(_ sender: Any) {
        delegate?.savedLocationButtonTapped(location: addressLabel.text ?? "")
        navigationController?.popViewController(animated: true)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // set up location manager.
            setupLocationManager()
            checkLocationAuthorization()
            
        } else {
            // show alert letting the suer know they have to turn this on.
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // show an alert letting them know whats up
            break
        case .denied:
            // alert letting them know what to do.
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
           startTrackingUserLocation()
            
        @unknown default:
            break
        }
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitute = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitute)
    }
}
//MARK: - CLLocation Delegate

extension LocationViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = previousLocation else { return }
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print(error)
                return
            }
            guard let placemark = placemarks?.first else { return }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.name ?? ""
            let cityName = placemark.administrativeArea ?? ""
            let countryName = placemark.country ?? ""
            
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName) \(cityName), \(countryName)"
            }
        }
        
    }
}

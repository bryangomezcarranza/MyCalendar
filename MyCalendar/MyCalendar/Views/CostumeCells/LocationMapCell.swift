//
//  LocationMapCell.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/26/21.
//

import UIKit
import MapKit

class LocationMapCell: UITableViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.layer.cornerRadius = 12
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(location: String) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(location) { [weak self] placemarks, error in // weak added
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let placemarks = placemarks {
                // Get first placemark
                let placemark = placemarks[0]
                // Add Annotation
                if let location = placemark.location {
                    // Display the annotation
                    annotation.coordinate = location.coordinate
                    self?.mapView.addAnnotation(annotation)
                    // set zoom level
                    // For Xcode
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 4500, longitudinalMeters: 4000)
                    self?.mapView.setRegion(region, animated: false)
                }
            }
        }
    }
}

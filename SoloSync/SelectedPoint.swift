//
//  SelectedPoint.swift
//  SoloSync
//
//  Created by Kevin Li on 11/4/24.
//

import Foundation
import MapKit

class SelectedPoint: NSObject, MKAnnotation{
    
    let title: String?
    let location: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, location: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.location = location
        self.coordinate = coordinate
    }
    
    var subtitle: String? {
        return location
    }
}

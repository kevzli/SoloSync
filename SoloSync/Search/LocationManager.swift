//
//  LocationManager.swift
//  SoloSync
//
//  Created by Aaron Chen on 2024/12/1.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
//            break
            
        case .restricted:
            print("DEBUG: Restricted")
//            break
            
        case .denied:
            print("DEBUG: Denied")
//            break
            
        case .notDetermined:
            print("DEBUG: Not determined")
//            manager.requestWhenInUseAuthorization()
//            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.userLocation = location
    }
}

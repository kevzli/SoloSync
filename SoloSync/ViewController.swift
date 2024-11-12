//
//  ViewController.swift
//  SoloSync
//
//  Created by Kevin Li on 11/3/24.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var switchValue: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addPin(_:)))
        mapView.addGestureRecognizer(tapGesture)
        // insertUser(name: "Bob", password: "123456", email: "123@wustl.edu")
        LocationInfoManager.shared.fetchAllAnnotations { [weak self] annotations in
                    for locationInfo in annotations {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = locationInfo.coordinate
                        annotation.title = locationInfo.note
                        self?.mapView.addAnnotation(annotation)
                    }
                }
    }

    @IBAction func changeMap(_ sender: Any) {
        if (switchValue.isOn){
            mapView.mapType = .satellite
        } else{
            mapView.mapType = .standard
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        let alert = UIAlertController(title: "Add New Location", message: "Tap a location on the map to add an annotation with details.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleAddPin(_:)))
                    self.mapView.addGestureRecognizer(tapGesture)
                }
                
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
    }
    
    @objc func handleAddPin(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
               
        mapView.removeGestureRecognizer(sender)
               
        addInfo(for: coordinate)
    }
    
    func addInfo(for coordinate: CLLocationCoordinate2D) {
        let addInfoViewController = AddInfoViewController()
                addInfoViewController.coordinate = coordinate
                present(addInfoViewController, animated: true) {
                    if let locationInfo = LocationInfoManager.shared.currentLocationInfo {
                        print("called")
                        self.addAnnotation(for: locationInfo)
                    }
                }
        }
    
    func addAnnotation(for locationInfo: LocationInfo) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationInfo.coordinate
            annotation.title = locationInfo.note
            mapView.addAnnotation(annotation)
            
            if let image = locationInfo.image {
                print("Received image: \(image)")

            }
        }
}


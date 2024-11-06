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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }

    @IBAction func changeMap(_ sender: Any) {
        if (switchValue.isOn){
            mapView.mapType = .satellite
        } else{
            mapView.mapType = .standard
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        let somePoint1 = SelectedPoint(title: "Some Place 1", location: "Famous Place", coordinate: CLLocationCoordinate2DMake(41.890158, 12.492185))
        
        mapView.addAnnotation(somePoint1)
    }
    
    @objc func mapTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Present UI to add notes and pictures for the selected location
        addInfo(for: coordinate)
    }
    
    func addInfo(for coordinate: CLLocationCoordinate2D){
        let addInfoViewController = AddInfoViewController()
        
        
    }
}


//
//  ViewController.swift
//  SoloSync
//
//  Created by Kevin Li on 11/3/24.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var switchValue: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.layer.addSublayer(gradientLayer)
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addPin(_:)))
        mapView.addGestureRecognizer(tapGesture)
        // insertUser(name: "Z", password: "1234567", email: "1234@wustl.edu")
        // login(user_email: "1234@wustl.edu", user_password: "1234567")
       // updateUsername(user_email: "1234@wustl.edu", new_name: "Z")
//        var locationTest: [LocationInfo] = [
//            LocationInfo(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), note: "test", image: nil)
//        ]
//        LocationInfoManager.shared.saveLocationInfoToAPI(locationTest[0])
        mapView.delegate = self
        
        LocationInfoManager.shared.fetchAllAnnotations { [weak self] annotations in
                    print(annotations)
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
               
        LocationInfoManager.shared.fetchAllAnnotations { [weak self] annotations in
                if let matchingAnnotation = annotations.first(where: {
                    $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude
                }) {
                    //Matching annotation found
                    DispatchQueue.main.async {
                        let annotationDetailsVC = AnnotationDetailsViewController()
                        //
                        //populate new view controller with fetched data
                        //
                        self?.present(annotationDetailsVC, animated: true, completion: nil)
                    }
                } else {
                    //No matching annotation, add a new pin
                    DispatchQueue.main.async {
                        self?.addInfo(for: coordinate)
                    }
                }
            }
    }
    
    func addInfo(for coordinate: CLLocationCoordinate2D) {
        let addInfoViewController = AddInfoViewController()
                addInfoViewController.coordinate = coordinate
                present(addInfoViewController, animated: true) {
                    if let locationInfo = LocationInfoManager.shared.currentLocationInfo {
                        print("called")
                        self.addAnnotation(for: locationInfo)
                        LocationInfoManager.shared.saveLocationInfoToAPI(locationInfo)
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


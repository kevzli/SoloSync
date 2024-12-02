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
    
    private var annotations: [LocationInfo] = []
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAddPin(_:)))
        self.mapView.addGestureRecognizer(tapGesture)
        mapView.addGestureRecognizer(tapGesture)
        // insertUser(name: "Z", password: "1234567", email: "1234@wustl.edu")
        // login(user_email: "1234@wustl.edu", user_password: "1234567")
       // updateUsername(user_email: "1234@wustl.edu", new_name: "Z")
//        var locationTest: [LocationInfo] = [
//            LocationInfo(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), note: "test", image: nil)
//        ]
//        LocationInfoManager.shared.saveLocationInfoToAPI(locationTest[0])
        mapView.delegate = self
        preloadAnnotations()
//        LocationInfoManager.shared.fetchAllAnnotations { [weak self] annotations in
//                    print(annotations)
//                    for locationInfo in annotations {
//                        let annotation = MKPointAnnotation()
//                        annotation.coordinate = locationInfo.coordinate
//                        annotation.title = locationInfo.note
//                        self?.mapView.addAnnotation(annotation)
//                    }
//                }
    }
    
    private func preloadAnnotations() {
            DispatchQueue.global(qos: .background).async { [weak self] in
                LocationInfoManager.shared.fetchAllAnnotations { annotations in
                    DispatchQueue.main.async {
                        self?.annotations = annotations
                        AllAnnotations = annotations
                        for locationInfo in annotations {
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = locationInfo.coordinate
                            annotation.title = locationInfo.note
                            self?.mapView.addAnnotation(annotation)
                        }
                    }
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
//                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleAddPin(_:)))
                    return
                }
                
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
    }
    
    @objc func handleAddPin(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)


        if let matchingAnnotation = annotations.first(where: {
            abs($0.coordinate.latitude - coordinate.latitude) < 0.1 &&
            abs($0.coordinate.longitude - coordinate.longitude) < 0.1
        }) {
            openAnnotationDetails(for: matchingAnnotation)
            print("debug1")
        } else {
            addInfo(for: coordinate)
            print("debug2")
        }
    }
    
    func openAnnotationDetails(for annotation: LocationInfo) {
            let annotationDetailsVC = AnnotationDetailsViewController()
            annotationDetailsVC.coordinate = annotation.coordinate
            annotationDetailsVC.comments = [annotation.note]
            annotationDetailsVC.images = [annotation.image].compactMap { $0 }
            annotationDetailsVC.socialMediaHandles = [annotation.socialMedia]
            present(annotationDetailsVC, animated: true)
        }
    
    
    func addInfo(for coordinate: CLLocationCoordinate2D) {
        let addInfoViewController = AddInfoViewController()
        addInfoViewController.coordinate = coordinate

        addInfoViewController.completion = { [weak self] locationInfo in
            guard let self = self else { return }
            self.annotations.append(locationInfo)
            self.addAnnotation(for: locationInfo)
            LocationInfoManager.shared.saveLocationInfoToAPI(locationInfo)
        }

        present(addInfoViewController, animated: true)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "Annotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                let detailButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = detailButton
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let tappedAnnotation = annotationView.annotation else { return }

            LocationInfoManager.shared.checkIfAnnotationExists(at: tappedAnnotation.coordinate) { [weak self] exists, matchingAnnotation in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    if exists, let annotation = matchingAnnotation {
                        self.openAnnotationDetails(for: annotation)
                    } else {
                        print("No matching annotation found in the database.")
                    }
                }
            }
        }
}


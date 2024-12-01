//
//  SearchViewController.swift
//  SoloSync
//
//  Created by Aaron Chen on 2024/11/27.
//

import UIKit
import SwiftUI

class SearchViewController: UIViewController {
    @ObservedObject var locationManager = LocationManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if locationManager.userLocation == nil {
            locationManager.requestLocation()
        } else {
            print(locationManager.userLocation!)
        }
        let swiftUIView = ContentView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    

}

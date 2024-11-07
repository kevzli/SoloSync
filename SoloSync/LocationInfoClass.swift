//
//  LocationInfoClass.swift
//  SoloSync
//
//  Created by Kevin Li on 11/6/24.
//

import Foundation
import UIKit
import CoreLocation

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

struct LocationInfo {
    var coordinate: CLLocationCoordinate2D
    var note: String
    var image: UIImage?
}

class LocationInfoManager {
    
    static let shared = LocationInfoManager()
    private init() {}
    
    var currentLocationInfo: LocationInfo?

    func saveLocationInfoToAPI(_ locationInfo: LocationInfo) {
        currentLocationInfo = locationInfo
        
        guard let url = URL(string: "http://ec2-3-144-195-16.us-east-2.compute.amazonaws.com/api/add_location.php") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        let mimeType = "image/jpeg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"note\"\r\n\r\n")
        body.appendString("\(locationInfo.note)\r\n")
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"latitude\"\r\n\r\n")
        body.appendString("\(locationInfo.coordinate.latitude)\r\n")

        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"longitude\"\r\n\r\n")
        body.appendString("\(locationInfo.coordinate.longitude)\r\n")
        
        if let imageData = locationInfo.image?.jpegData(compressionQuality: 0.8) {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"location.jpg\"\r\n")
            body.appendString("Content-Type: \(mimeType)\r\n\r\n")
            body.append(imageData)
            body.appendString("\r\n")
        }
        
        body.appendString("--\(boundary)--\r\n")
        
        request.httpBody = body as Data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }.resume()
    }
}


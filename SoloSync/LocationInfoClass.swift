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
    
    func saveLocationInfoToAPI(_ locationInfo: LocationInfo, userId: Int = 2) {
        // Convert coordinate to string
        print("saveLocationInfoToAPI worked")
        let coordinateString = "\(locationInfo.coordinate.latitude),\(locationInfo.coordinate.longitude)"
        
        // Create a unique name for the image if it exists, otherwise default to nil
        var imageName: String? = nil
        var imageData: Data? = nil // Declare imageData with the correct type
    
        if let image = locationInfo.image {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let timestamp = dateFormatter.string(from: Date())
            
            // Combine user ID, coordinate string, and timestamp for the image name
            imageName = "\(userId)_\(coordinateString)_\(timestamp).jpg"
            uploadImageTPHP(image: image, imageName: imageName!)
        }
        
        // Asynchronously call `shareNote` at the end of this function
        DispatchQueue.global().async {
            let imageNameToUse = imageName ?? ""
            let imageDataToUse = imageData
            
            // Pass imageData along with other parameters to `shareNote`
            shareNote(user_id: userId, coordinate: coordinateString, note: locationInfo.note, imageName: imageNameToUse, imageUpload: imageDataToUse) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let jsonResponse):
                        print("Note shared successfully: \(jsonResponse)")
                    case .failure(let error):
                        print("Failed to share note: \(error)")
                    }
                }
            }
        }
    }
    
    func fetchAllAnnotations(completion: @escaping ([LocationInfo]) -> Void) {
        guard let url = URL(string:  "http://3.144.195.16:3000/get_all_annotations") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add body data if necessary
        request.httpBody = try? JSONSerialization.data(withJSONObject: [:], options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching annotations:", error)
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            // Print raw response data to debug
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response from server:", responseString)
            }

            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    var annotations: [LocationInfo] = []
                    for json in jsonArray {
                        if let coordinateString = json["coordinate"] as? String,
                           let note = json["note"] as? String {

                            let imageURL = json["imageurl"] as? String
                            // Todo: Add reading image
                            print("note:", note)
                            print("imageURL:", imageURL ?? "No image URL")
                            
                            // Parse the coordinate
                            let coordinates = coordinateString.split(separator: ",")
                            if let latitude = Double(coordinates[0]), let longitude = Double(coordinates[1]) {
                                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                
                                // Create LocationInfo object
                                let locationInfo = LocationInfo(coordinate: coordinate, note: note, image: nil)  // You can handle image loading if needed
                                
                                annotations.append(locationInfo)
                            }
                    
                        }
                    }
                    
                    DispatchQueue.main.async {
                        completion(annotations)
                    }
                } else {
                    print("JSON response format is not as expected.")
                }
            } catch {
                print("Error parsing annotations:", error)
            }
        }.resume()
    }
}


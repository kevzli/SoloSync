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
        print(locationInfo)
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
            
            // Convert the image to Data for storage or uploading, if needed
            if let data = image.jpegData(compressionQuality: 0.8) {
                imageData = data
                print("Generated image name: \(imageName!)")
                print("Image data size: \(imageData!.count) bytes")
            }
        }
        
        // Asynchronously call `shareNote` at the end of this function
        DispatchQueue.global().async {
            let imageNameToUse = imageName ?? ""
            let imageDataToUse = imageData
            
            // Pass imageData along with other parameters to `shareNote`
            shareNote(user_id: userId, coordinate: coordinateString, note: locationInfo.note, imageName: imageNameToUse, imageUpload: imageDataToUse!) { result in
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
            // Replace "yourserver.com" with your actual server URL
            guard let url = URL(string: "http://yourserver.com/get_all_annotations") else {
                print("Invalid URL")
                return
            }

            // Create a GET request
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching annotations:", error)
                    return
                }

                // Ensure data is not nil
                guard let data = data else { return }

                do {
                    // Parse JSON response into an array of dictionaries
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        var annotations: [LocationInfo] = []

                        // Iterate over each dictionary to convert to LocationInfo
                        for json in jsonArray {
                            if let coordinateString = json["coordinate"] as? String,
                               let note = json["note"] as? String,
                               let imageURL = json["image_url"] as? String {
                                
                                // Parse coordinate string (latitude,longitude)
                                let coordinates = coordinateString.split(separator: ",")
                                if let latitude = Double(coordinates[0]),
                                   let longitude = Double(coordinates[1]) {
                                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    
                                    // Create LocationInfo object (image can be loaded from URL if needed)
                                    let locationInfo = LocationInfo(coordinate: coordinate, note: note, image: nil)
                                    annotations.append(locationInfo)
                                }
                            }
                        }

                        // Call completion handler on main thread to return annotations
                        DispatchQueue.main.async {
                            completion(annotations)
                        }
                    }
                } catch {
                    print("Error parsing annotations:", error)
                }
            }.resume()
        }
    
}


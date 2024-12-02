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
var AllAnnotations: [LocationInfo] = []
struct LocationInfo {
    var coordinate: CLLocationCoordinate2D
    var note: String
    var socialMedia: String = "Nothing here"
    var image: UIImage?
    var creator: Int = -1
    var noteId: Int = -1
}

class LocationInfoManager {
    
    static let shared = LocationInfoManager()
    private init() {}
    
    var currentLocationInfo: LocationInfo?
    
    func saveLocationInfoToAPI(_ locationInfo: LocationInfo) {
        guard let userIdString = UserDefaults.standard.string(forKey: "userId"),
              let userId = Int(userIdString) else {
            print("No valid user ID found")
            return
        }
        print("UserId found and converted to Int: \(userId)")
        
        let coordinateString = "\(locationInfo.coordinate.latitude),\(locationInfo.coordinate.longitude)"
        
        //create a unique name for the image
        var imageName: String? = nil
        let imageData: Data? = nil
    
        if let image = locationInfo.image {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let timestamp = dateFormatter.string(from: Date())
            
            //combine user ID, coordinate string, and timestamp
            imageName = "\(userId)_\(coordinateString)_\(timestamp).jpg"
            uploadImageTPHP(image: image, imageName: imageName!)
        }
        
        //asynchronously call
        DispatchQueue.global().async {
            let imageNameToUse = imageName ?? ""
            let imageDataToUse = imageData
            
            shareNote(user_id: userId, coordinate: coordinateString, note: locationInfo.note, imageName: imageNameToUse, socialMediaString: locationInfo.socialMedia, imageUpload: imageDataToUse) { result in
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

            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    var annotations: [LocationInfo] = []

                    for json in jsonArray {
                        if let coordinateString = json["coordinate"] as? String,
                           let note = json["note"] as? String,
                           let note_id = json["note_id"] as? Int,
                           let creatorId = json["user_id"] as? Int {

                            let social = json["socialMedia"] as? String
                            let imageURL = json["imageurl"] as? String

                            let coordinates = coordinateString.split(separator: ",")
                            if let latitude = Double(coordinates[0]), let longitude = Double(coordinates[1]) {
                                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                                let locationInfo = LocationInfo(coordinate: coordinate, note: note, socialMedia: social ?? "Nothing", image: UIImage(named: "placeholder"), creator: creatorId, noteId: note_id)
                                annotations.append(locationInfo)

                                if let imageURL = imageURL {
                                    fetchImage(ImgUrl: imageURL) { image in
                                        DispatchQueue.main.async {
                                            if let image = image {
                                                if let index = annotations.firstIndex(where: { $0.noteId == note_id }) {
                                                    annotations[index].image = image
                                                    if index < AllAnnotations.count {
                                                                            AllAnnotations[index].image = image
                                                                        } else {
                                                                            print("Warning: Index out of bounds for AllAnnotations")
                                                                        }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
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
                print("Failed to parse JSON:", error)
            }
        }.resume()
    }
    
    func checkIfAnnotationExists(at coordinate: CLLocationCoordinate2D, completion: @escaping (Bool, LocationInfo?) -> Void) {
        fetchAllAnnotations { annotations in
                let matchingAnnotation = annotations.first {
                    abs($0.coordinate.latitude - coordinate.latitude) < 0.001 &&
                    abs($0.coordinate.longitude - coordinate.longitude) < 0.001
                }
                
                if let annotation = matchingAnnotation {
                    completion(true, annotation)
                } else {
                    completion(false, nil)
                }
            }
        }
}


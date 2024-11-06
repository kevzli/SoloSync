//
//  DataConnection.swift
//  MapTest
//
//  Created by ztlllll on 10/30/24.
//

import Foundation
import UIKit

var images: [UIImage] = []

func fetchData(completion: @escaping (UIImage?) -> Void) {
    let urlString = "http://ec2-3-144-195-16.us-east-2.compute.amazonaws.com/~ec2-user/images/q1_char.png"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Failed to fetch image:", error)
            completion(nil)
            return
        }
        
        guard let data = data, let image = UIImage(data: data) else {
            print("Failed to decode image data.")
            completion(nil)
            return
        }
        
        completion(image)
    }.resume()
}


func uploadImage(image: UIImage, imageName: String) {
    // Prepare the URL for your EC2 instance
    guard let url = URL(string: "http://ec2-3-144-195-16.us-east-2.compute.amazonaws.com/upload.php") else {
        print("Invalid URL")
        return
    }
    
    // Convert UIImage to JPEG data
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        print("Unable to convert image to data")
        return
    }
    
    // Create the request with URL and HTTP method
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Generate a unique boundary string for multipart/form-data
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    // Build the multipart form data body
    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(imageName).jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    // Add the body to the request
    request.httpBody = body
    
    // Start the upload task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error uploading image: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            print("Image uploaded successfully!")
        } else {
            print("Failed to upload image. Server responded with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        }
    }
    
    task.resume()
}

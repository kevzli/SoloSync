//
//  ConnectSQL.swift
//  MapTest
//
//  Created by ztlllll on 11/6/24.
//

import Foundation
import UIKit

func insertUser(name: String, password: String, email: String) {

    guard let url = URL(string: "http://localhost:3000/insert") else {
        print("Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = ["username": name, "password": password, "email": email]
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
    } catch {
        print("Error encoding JSON data: \(error)")
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }

        if let data = data {
            // Print raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }

            // Try to parse the response as JSON
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("JSON Response: \(jsonResponse)")
                } else {
                    print("Response is not JSON format.")
                }
            } catch {
                print("Error parsing response: \(error)")
            }
        }
    }

    task.resume()
}

func shareNote(user_id: Int, coordinate: String, note: String, imageName: String, imageUpload: Data?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    // Part 1: Share Note
    guard let url = URL(string: "http://localhost:3000/share") else {
        print("Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let token = UserDefaults.standard.string(forKey: "userToken") {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    } else {
        print("No token found")
        return
    }

    let body: [String: Any] = ["user_id": user_id, "coordinate": coordinate, "note": note, "image_url": imageName]
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
    } catch {
        print("Error encoding JSON data: \(error)")
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completion(.failure(error))
            return
        }

        if let data = data {
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }

            // Try to parse the response as JSON
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(jsonResponse))
                } else {
                    print("Response is not JSON format.")
                }
            } catch {
                print("Error parsing response: \(error)")
                completion(.failure(error))
            }
        }
    }

    task.resume()
}


func uploadImageTPHP(image: UIImage, imageName: String) {
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


func login(user_email: String, user_password: String) {
    guard let url = URL(string: "http://localhost:3000/login") else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = ["email": user_email, "password": user_password]
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
    } catch {
        print("Error encoding JSON data: \(error)")
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        if let data = data {
            // Print raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            // Try to parse the response as JSON
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("JSON Response: \(jsonResponse)")
                    
                    // Check for token in the response
                    if let token = jsonResponse["token"] as? String {
                        // Store token securely for future requests
                        UserDefaults.standard.set(token, forKey: "userToken")
                    } else {
                        print("Token not found in the response.")
                    }
                } else {
                    print("Response is not JSON format.")
                }
            } catch {
                print("Error parsing response: \(error)")
            }
        }
    }
    
    task.resume()
}

func updateUsername(user_email: String, new_name: String) {
    guard let url = URL(string: "http://localhost:3000/update_user") else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Retrieve the token from UserDefaults
    if let token = UserDefaults.standard.string(forKey: "userToken") {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    } else {
        print("No token found")
        return
    }
    
    let body: [String: Any] = ["email": user_email, "newUsername": new_name]
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
    } catch {
        print("Error encoding JSON data: \(error)")
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }
        
        if let data = data {
            // Print raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            // Parse the JSON response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("JSON Response: \(jsonResponse)")
                } else {
                    print("Response is not JSON format.")
                }
            } catch {
                print("Error parsing response: \(error)")
            }
        }
    }
    
    task.resume()
}

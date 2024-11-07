//
//  ConnectSQL.swift
//  MapTest
//
//  Created by ztlllll on 11/6/24.
//

import Foundation

func insertUser(name: String, password: String) {

    guard let url = URL(string: "http://localhost:3000/insert") else {
        print("Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = ["username": name, "password": password]
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



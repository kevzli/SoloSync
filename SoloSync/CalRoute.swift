//
//  CalRoute.swift
//  SoloSync
//
//  Created by Jialiang Yuan on 11/11/24.
//

import Foundation

class CalRoute{
    
    private let apiKey: String
    
    init() {
        self.apiKey = "AIzaSyAt6L9pHUW2PGd3D7en0H4u1FatwlQH73s"
    }
    
    //use google api calculate est. time and description
    func calt(start: String, end: String, stops: [String], completion: @escaping (String?, String?) -> Void) {
 
        var url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start)&destination=\(end)&key=\(apiKey)"
        
        //join any stop to url
        if !stops.isEmpty {
            let pts = stops.joined(separator: "|")
            url += "&waypoints=\(pts)"
        }

        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        
        guard let url = URL(string: url) else {
            completion(nil, nil)
            return
        }
        
        //send request to google
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil, nil)
                return
            }
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            do {
                //load json
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                //get routes
                if let json = jsonObject as? [String: Any] {
                    if let routes = json["routes"] as? [[String: Any]], !routes.isEmpty {
                        
                        let f = routes[0]
                        //store the instruction in description
                        var des : [String] = []
                        if let legs = f["legs"] as? [[String: Any]]{
                            var t = 0
                            
                            for l in legs{
                                
                                if let d = l["duration"] as? [String: Any],
                                   let val = d["value"] as? Int{
                                    t += val
                                }
                                if let steps = l["steps"] as? [[String: Any]]{
                                    for (i, s) in steps.enumerated(){
                                        //filter the html using regex
                                        var ins = s["html_instructions"] as? String ?? "Ins"
                                        ins = ins.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                                        des.append("\(i + 1). \(ins)")
                                    }
                                }
                            }
                            //calculate time
                            let h = t/3600
                            let mins = (t%3600) / 60
                            let est = "\(h)h \(mins)m"
                            
                            //return string, so join the list
                            let desc = des.joined(separator: "\n")
                            
                            completion(est, desc)
                        }else{
                            completion(nil, nil)
                        }
                    }else{
                        completion(nil, nil)
                    }
                }
            }catch{
                completion(nil, nil)
            }
        }
        task.resume()
    }
}

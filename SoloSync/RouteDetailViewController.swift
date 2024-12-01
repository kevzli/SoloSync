//
//  RouteDetailViewController.swift
//  SoloSync
//
//  Created by Jialiang Yuan on 12/1/24.
//

import UIKit

class RouteDetailViewController: UIViewController {
    
    var des: String?
    
    private let desc =  UITextView()
    private let addBtn = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        
    }
    private func load() {
        desc.backgroundColor = UIColor(white: 0.98, alpha: 1)
        desc.isEditable = false
        desc.text = des
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.layer.cornerRadius = 10
        
        addBtn.setTitle("Save Route", for: .normal)
        addBtn.setTitleColor(.white, for: .normal)
        addBtn.backgroundColor = .systemBlue
        addBtn.layer.cornerRadius = 8
        addBtn.addTarget(self, action: #selector(addRoute), for: .touchUpInside)
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(desc)
        view.addSubview(addBtn)
        
        NSLayoutConstraint.activate([
            desc.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            desc.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            desc.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            desc.heightAnchor.constraint(equalToConstant: 500),
                    
            addBtn.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 20),
            addBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            addBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            addBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let g = CAGradientLayer()
        g.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.frame = view.bounds
                
        let bg = UIView(frame: view.bounds)
        bg.layer.addSublayer(g)
        view.addSubview(bg)
        view.sendSubviewToBack(bg)
    }
    
    @objc private func addRoute() {
        self.save(id:1, des: des!)
        
        guard let des = des else {return}
        
        let url = URL(string: "http://3.144.195.16:3000/addRoute")
        var req = URLRequest(url: url!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["d": des]
        
        do{
            let json = try JSONSerialization.data(withJSONObject: body, options: [])
            req.httpBody = json
        }catch{
            show(title: "Error", msg: "convert json err")
            return
        }
        
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.show(title: "Error", msg: "Request failed: \(error.localizedDescription)")
                }
                return
            }
            guard let data = data else{
                DispatchQueue.main.async {
                    self.show(title: "Error", msg: "No response data received.")
                }
                return
            }
            do{
                if let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let msg = response["message"] as? String, let id = response["routeId"] as? Int {
                    DispatchQueue.main.async {
                        self.save(id: id, des: des)
                        self.show(title: "Success", msg: msg)
                    }
                
                }else{
                    DispatchQueue.main.async {
                        self.show(title: "Error", msg: "Invalid response format.")
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    self.show(title: "Error", msg: "Invalid response format.")
                }
                return
            }
            
        }
        task.resume()
        
    }
    
    private func show(title: String, msg: String) {
        let m = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        m.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(m, animated: true)
    }
    
    //save the info to userdefault
    private func save(id: Int, des: String){
        var saved = UserDefaults.standard.array(forKey: "des") as? [[String:Any]] ?? []
        let nd : [String: Any] = ["id": id, "description": des]
        saved.append(nd)
        UserDefaults.standard.set(saved, forKey: "des")
    }
    
}

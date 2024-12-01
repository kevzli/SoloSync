//
//  RouteDetailViewController.swift
//  SoloSync
//
//  Created by Jialiang Yuan on 12/1/24.
//

import UIKit

//show the detail of saved, add share btn
class SVShareViewController: UIViewController {
    
    var des: String?
    var routeId: Int?
    
    private let desc =  UITextView()
    private let shareBtn = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        
    }
    //func to set constraints
    private func load() {
        desc.isEditable = false
        desc.text = des
        desc.translatesAutoresizingMaskIntoConstraints = false
        navigationController?.navigationBar.tintColor = .white
        desc.layer.cornerRadius = 10
        desc.backgroundColor = UIColor(white: 0.98, alpha: 1)
        
        shareBtn.setTitle("Share Route", for: .normal)
        shareBtn.setTitleColor(.white, for: .normal)
        shareBtn.backgroundColor = .systemBlue
        shareBtn.layer.cornerRadius = 8
        shareBtn.addTarget(self, action: #selector(shareRoute), for: .touchUpInside)
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(desc)
        view.addSubview(shareBtn)
        
        //auto layout
        NSLayoutConstraint.activate([
            desc.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            desc.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            desc.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            desc.heightAnchor.constraint(equalToConstant: 500),
                    
            shareBtn.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 20),
            shareBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            shareBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            shareBtn.heightAnchor.constraint(equalToConstant: 50)
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
    
    //change is_share in mysql
    @objc private func shareRoute() {
        
        guard let routeId = routeId else {
            show(title: "Error", msg: "Need ID")
            return
        }
        let url = URL(string: "http://3.144.195.16:3000/shareRoute")
        var req = URLRequest(url: url!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["id": routeId]
        
        do{
            let json = try JSONSerialization.data(withJSONObject: body, options: [])
            req.httpBody = json
        }catch{
            show(title: "Error", msg: "convert json err")
            return
        }
        
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            guard let data = data else{
                DispatchQueue.main.async {
                    self.show(title: "Error", msg: "No response")
                }
                return
            }
            
            do{
                if let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let msg = response["message"] as? String {
                    DispatchQueue.main.async {
                        self.show(title: "Success", msg: msg)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.show(title: "Error", msg: "Error response")
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    self.show(title: "Error", msg: "Error get response")
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
    
    
}

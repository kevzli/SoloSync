//
//  SavedViewController.swift
//  SoloSync
//
//  Created by Jialiang Yuan on 12/1/24.
//

import UIKit
class SavedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    //cell of tableview, only show name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath)
        let route = routes[indexPath.row]
        let d = route["description"] as? String ?? "Route"
        //filter
        let t = d.components(separatedBy: "\n").first ?? "Route"
        cell.textLabel?.text = t
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        return cell
    }
    
    //open the saved share view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let VC = SVShareViewController()
        let route = routes[indexPath.row]
        VC.des = route["description"] as? String
        VC.routeId = route["id"] as? Int
        navigationController?.pushViewController(VC, animated: true)
    }
    
    var routes: [[String: Any]] = []
    
    private let theview = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routes = UserDefaults.standard.array(forKey: "des") as? [[String: Any]] ?? []
        load()
    }
    
    //setup
    private func load() {
        theview.translatesAutoresizingMaskIntoConstraints = false
        theview.dataSource = self
        theview.delegate = self
        theview.register(UITableViewCell.self, forCellReuseIdentifier: "RouteCell")
        
        theview.separatorStyle = .singleLine
        theview.backgroundColor = .clear
        
        view.addSubview(theview)
        
        title = "Saved Routes"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        
        //layout
        NSLayoutConstraint.activate([
            theview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            theview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            theview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            theview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        //color background
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
    
}

//
//  SavedViewController.swift
//  SoloSync
//
//  Created by Jialiang Yuan on 12/1/24.
//

import UIKit

class ShareViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    //display only title
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath)
        let route = routes[indexPath.row]
        let d = route["description"] as? String ?? "Route"
        let t = d.components(separatedBy: "\n").first ?? "Route"
        
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        cell.textLabel?.text = t
        return cell
    }
    
    //click jump to a new controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let VC = ShareDesViewController()
        let route = routes[indexPath.row]
        VC.des = route["description"] as? String
        navigationController?.pushViewController(VC, animated: true)
    }
    
    var routes: [[String: Any]] = []
    
    private let theview = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetch()
        load()
    }
    
    //setup
    private func load() {
        theview.translatesAutoresizingMaskIntoConstraints = false
        theview.dataSource = self
        theview.delegate = self
        theview.separatorStyle = .singleLine
        theview.backgroundColor = .clear
        
        theview.register(UITableViewCell.self, forCellReuseIdentifier: "RouteCell")
        view.addSubview(theview)
        
        //format navbar
        title = "Shared Routes"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        
        NSLayoutConstraint.activate([
            theview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            theview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            theview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            theview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        //color bg
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
    
    //get all route with is_shared set, currently there's no delete option
    private func fetch(){
        let url = URL(string: "http://3.144.195.16:3000/getRoute")
        
        let task = URLSession.shared.dataTask(with: url!) { [weak self] data, response, err in
            let data = data!
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self?.routes = json
                        self?.theview.reloadData()
                    }
                }
            }catch{
                return
            }
        }
        task.resume()
    }
    
}

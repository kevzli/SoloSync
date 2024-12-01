//
//  RouteDetailViewController.swift
//  SoloSync
//
//  Created by Jialiang Yuan on 12/1/24.
//

import UIKit

class ShareDesViewController: UIViewController {
    
    var des: String?
    
    private let desc =  UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    //only show des
    private func load() {
        desc.backgroundColor = UIColor(white: 0.98, alpha: 1)
        desc.isEditable = false
        desc.text = des
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.layer.cornerRadius = 10
        
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(desc)
        
        NSLayoutConstraint.activate([
            desc.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            desc.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            desc.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            desc.heightAnchor.constraint(equalToConstant: 550),
                    
        ])
        
        //format of background
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

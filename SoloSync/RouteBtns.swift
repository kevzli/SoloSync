//
//  RouteBtns.swift
//  SoloSync
//
//  Created by Jialiang Yuan on 11/10/24.
//

import UIKit

class RouteBtns: UIView {
    let s = UIButton(type: .system)
    let share = UIButton(type: .system)
    
    //stack 2 btns in stack view
    private let btns: UIStackView
    
    override init(frame: CGRect){
        s.setTitle("Saved Route", for: .normal)
        s.setTitleColor(.systemBlue, for: .normal)
        s.titleLabel?.numberOfLines = 0
        s.titleLabel?.textAlignment = .center
        s.titleLabel?.lineBreakMode = .byWordWrapping
        
        share.setTitle("Share Route", for: .normal)
        share.setTitleColor(.systemBlue, for: .normal)
        share.titleLabel?.numberOfLines = 0
        share.titleLabel?.textAlignment = .center
        share.titleLabel?.lineBreakMode = .byWordWrapping
        
        //format of stack view
        btns = UIStackView(arrangedSubviews: [s, share])
        btns.axis = .horizontal
        btns.alignment = .center
        btns.spacing = 10
        btns.distribution = .fillEqually
        btns.translatesAutoresizingMaskIntoConstraints = false
        btns.layer.cornerRadius = 15
        btns.backgroundColor = UIColor(white: 0.97, alpha: 0.9)
        btns.isLayoutMarginsRelativeArrangement = true
        btns.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        super.init(frame: frame)
        setupView()
    }
    

        
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    //set height and constraints
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(btns)
        
        NSLayoutConstraint.activate([
            btns.topAnchor.constraint(equalTo: topAnchor),
            btns.leadingAnchor.constraint(equalTo: leadingAnchor),
            btns.trailingAnchor.constraint(equalTo: trailingAnchor),
            btns.bottomAnchor.constraint(equalTo: bottomAnchor),
            btns.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

}

//
//  RouteBtns.swift
//  SoloSync
//
//  Created by Jialiang Yuan on 11/10/24.
//

import UIKit

class RouteBtns: UIView {
    
    //stack 4 btns in stack view
    private let btns: UIStackView = {
        let cr = UIButton(type: .system)
        cr.setTitle("Create Route", for: .normal)
        cr.setTitleColor(.systemBlue, for: .normal)
        cr.titleLabel?.numberOfLines = 0
        cr.titleLabel?.textAlignment = .center
        cr.titleLabel?.lineBreakMode = .byWordWrapping
        
        let s = UIButton(type: .system)
        s.setTitle("Saved Route", for: .normal)
        s.setTitleColor(.systemBlue, for: .normal)
        s.titleLabel?.numberOfLines = 0
        s.titleLabel?.textAlignment = .center
        s.titleLabel?.lineBreakMode = .byWordWrapping
        
        let d = UIButton(type: .system)
        d.setTitle("Download Route", for: .normal)
        d.setTitleColor(.systemBlue, for: .normal)
        d.titleLabel?.numberOfLines = 0
        d.titleLabel?.textAlignment = .center
        d.titleLabel?.lineBreakMode = .byWordWrapping
        
        let share = UIButton(type: .system)
        share.setTitle("Share Route", for: .normal)
        share.setTitleColor(.systemBlue, for: .normal)
        share.titleLabel?.numberOfLines = 0
        share.titleLabel?.textAlignment = .center
        share.titleLabel?.lineBreakMode = .byWordWrapping
        
        //format of stack view
        let st = UIStackView(arrangedSubviews: [cr, s, d, share])
        st.axis = .horizontal
        st.alignment = .center
        st.spacing = 10
        st.distribution = .fillEqually
        st.translatesAutoresizingMaskIntoConstraints = false
        st.layer.cornerRadius = 15
        st.backgroundColor = UIColor(white: 0.97, alpha: 0.9)
        st.isLayoutMarginsRelativeArrangement = true
        st.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        return st
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
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

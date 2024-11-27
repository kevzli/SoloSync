//
//  ProfileViewController.swift
//  SoloSync
//
//  Created by Kevin Li on 11/27/24.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    private var profileImageView: UIImageView!
    private var usernameLabel: UILabel!
    private var emailLabel: UILabel!
    
    var username: String = "user" //Replace with actual username from database
    var email: String = "useremail.com" //Replace with actual email from database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
    }
    
    private func setup() {
        profileImageView = UIImageView()
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemBlue
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 60
        profileImageView.clipsToBounds = true
        view.addSubview(profileImageView)
        
        usernameLabel = UILabel()
        usernameLabel.text = "Username: \(username)"
        usernameLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        usernameLabel.textColor = .darkGray
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)
        
        emailLabel = UILabel()
        emailLabel.text = "Email: \(email)"
        emailLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        emailLabel.textColor = .darkGray
        emailLabel.textAlignment = .center
        view.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

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
    private var backgroundView: UIView!

    var username: String = "Dave" // Replace with actual username
    var email: String = "Dave@example.com" // Replace with actual email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupProfileImage()
        setupLabels()
    }
    
    private func setupBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.layer.addSublayer(gradientLayer)
        self.backgroundView = backgroundView
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
    }
    
    private func setupProfileImage() {
        profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .white
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 60
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileImageView.layer.shadowOpacity = 0.5
        profileImageView.layer.shadowRadius = 5
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupLabels() {

        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "👤 \(username)"
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        usernameLabel.textColor = .white
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)
        
        emailLabel = UILabel()
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.text = "📧 \(email)"
        emailLabel.font = UIFont.systemFont(ofSize: 20)
        emailLabel.textColor = .white
        emailLabel.textAlignment = .center
        view.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 50),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 30),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

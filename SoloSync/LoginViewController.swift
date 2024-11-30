//
//  LoginViewController.swift
//  SoloSync
//
//  Created by Kevin Li on 11/27/24.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {

    private var usernameTextField: UITextField!
    private var passwordTextField: UITextField!
    private var loginButton: UIButton!
    private var signupButton: UIButton!
    private var backgroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.layer.addSublayer(gradientLayer)
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        setup()
    }

    private func setup() {
        usernameTextField = UITextField()
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.placeholder = "Email"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.keyboardType = .emailAddress
        usernameTextField.autocapitalizationType = .none
        view.addSubview(usernameTextField)
        
        passwordTextField = UITextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        
        loginButton = UIButton(type: .system)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        view.addSubview(loginButton)
        
        signupButton = UIButton(type: .system)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        signupButton.backgroundColor = .systemBlue
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.layer.cornerRadius = 10
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        view.addSubview(signupButton)
        
        NSLayoutConstraint.activate([

            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),
            usernameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.centerXAnchor.constraint(equalTo: usernameTextField.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: usernameTextField.widthAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 150),
            loginButton.centerXAnchor.constraint(equalTo: usernameTextField.centerXAnchor),
            loginButton.widthAnchor.constraint(equalTo: usernameTextField.widthAnchor, multiplier: 0.6),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            signupButton.centerXAnchor.constraint(equalTo: usernameTextField.centerXAnchor),
            signupButton.widthAnchor.constraint(equalTo: loginButton.widthAnchor),
            signupButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }


    @objc private func handleLogin() {
        guard let email = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        var loginResult: Result<String, Error>?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        // Call the login function
        login(user_email: email, user_password: password) { result in
            loginResult = result
            semaphore.signal()
        }
        
        // Wait for the semaphore signal
        semaphore.wait()
        
        // Handle the login result
        switch loginResult {
        case .success(let message):
            print(message) // Login successful message
            self.navigateToMainApp() // Navigate to the main app
        case .failure(let error):
            print("Login failed: \(error.localizedDescription)")
            showAlert(title: "Login Failed", message: "Incorrect password")
        case .none:
            print("Unexpected error: No result from login.")
            showAlert(title: "Error", message: "Unexpected error occurred.")
        }
    }
    
    @objc private func handleSignup() {
        guard let email = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        var SignupResult: Result<String, Error>?
        let semaphore = DispatchSemaphore(value: 0)
        
        insertUser(name: "Momo", password: password, email: email) { result in
            SignupResult = result
            semaphore.signal()
        }
        
        semaphore.wait()
        
        // Handle the login result
        switch SignupResult {
        case .success(let message):
            print(message) // Login successful message
            self.navigateToMainApp() // Navigate to the main app
        case .failure(let error):
            print("Signup failed: \(error.localizedDescription)")
            showAlert(title: "SignUo Failed", message: error.localizedDescription)
        case .none:
            print("Unexpected error: No result from signup.")
            showAlert(title: "Error", message: "Unexpected error occurred.")
        }
        
        
    }

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func navigateToMainApp() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Instantiate the view controller with the correct Storyboard ID
            if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                mainTabBarController.modalPresentationStyle = .fullScreen
                self.present(mainTabBarController, animated: true)
            } else {
                print("Error: Could not load MainTabBarController from storyboard.")
            }
        }
    }
}


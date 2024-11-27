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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
        
        let loginURL = URL(string: "http://ec2-3-144-195-16.us-east-2.compute.amazonaws.com/login")! // Replace with login endpoint
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                self?.showAlert(title: "Login Failed", message: "Unexpected response.")
                return
            }
            
            if responseString.contains("success") {
                DispatchQueue.main.async {
                    self?.navigateToMainApp()
                }
            } else {
                self?.showAlert(title: "Login Failed", message: "Invalid email or password.")
            }
        }.resume()
    }
    
    @objc private func handleSignup() {
        guard let email = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        let signupURL = URL(string: "http://ec2-3-144-195-16.us-east-2.compute.amazonaws.com/signup")! // Replace with signup endpoint
        var request = URLRequest(url: signupURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.showAlert(title: "Signup Failed", message: error.localizedDescription)
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                self?.showAlert(title: "Signup Failed", message: "Unexpected response.")
                return
            }
            
            if responseString.contains("success") {
                DispatchQueue.main.async {
                    self?.navigateToMainApp()
                }
            } else {
                self?.showAlert(title: "Signup Failed", message: responseString)
            }
        }.resume()
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
            let mainVC = ViewController()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true)
        }
    }
}


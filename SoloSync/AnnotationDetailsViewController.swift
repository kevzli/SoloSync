//
//  AnnotationDetailsViewController.swift
//  SoloSync
//
//  Created by Kevin Li on 11/30/24.
//

import Foundation
import UIKit
import CoreLocation

class LocationDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var coordinate: CLLocationCoordinate2D!
    var images: [UIImage] = [] // Preloaded images from the database
    var comments: [String] = [] // Preloaded comments from the database
    
    private var imageView: UIImageView!
    private var addImageButton: UIButton!
    private var commentsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupImageView()
        setupAddImageButton()
        setupCommentsTableView()
        fetchLocationDetails()
    }
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
    }
    
    private func setupAddImageButton() {
        addImageButton = UIButton(type: .system)
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)), for: .normal)
        addImageButton.tintColor = .systemBlue
        addImageButton.addTarget(self, action: #selector(openAddInfoView), for: .touchUpInside)
        view.addSubview(addImageButton)
        
        NSLayoutConstraint.activate([
            addImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addImageButton.widthAnchor.constraint(equalToConstant: 60),
            addImageButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCommentsTableView() {
        commentsTableView = UITableView()
        commentsTableView.translatesAutoresizingMaskIntoConstraints = false
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
        view.addSubview(commentsTableView)
        
        NSLayoutConstraint.activate([
            commentsTableView.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 20),
            commentsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            commentsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func fetchLocationDetails() {
        // Fetch images and comments from the database based on the coordinate
    }
    
    @objc private func openAddInfoView() {
        let addInfoViewController = AddInfoViewController()
        addInfoViewController.coordinate = coordinate
        present(addInfoViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        cell.textLabel?.text = comments[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}

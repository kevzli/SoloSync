//
//  AnnotationDetailsViewController.swift
//  SoloSync
//
//  Created by Kevin Li on 11/30/24.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class AnnotationDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var coordinate: CLLocationCoordinate2D!
    var images: [UIImage] = []
    var comments: [String] = []
    var socialMediaHandles: [String] = []
    
    private var addImageButton: UIButton!
    private var commentsTableView: UITableView!
    private var imageStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupImageView()
        setupAddImageButton()
        setupCommentsTableView()
        fetchLocationDetails()
    }
    
    private func setupImageView() {
        imageStackView = UIStackView()
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        imageStackView.axis = .horizontal
        imageStackView.distribution = .fillEqually
        imageStackView.spacing = 6

        view.addSubview(imageStackView)

        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
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
            addImageButton.topAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: 15),
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
        commentsTableView.separatorStyle = .none // Remove default separators
        commentsTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell") // Register custom cell
        view.addSubview(commentsTableView)
        
        NSLayoutConstraint.activate([
            commentsTableView.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 20),
            commentsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            commentsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func fetchLocationDetails() {
        guard let coordinate = self.coordinate else {
            return
        }
        
        self.images = []
        self.comments = []
        self.socialMediaHandles = []

        for locationInfo in AllAnnotations {
            if coordinate.latitude == locationInfo.coordinate.latitude && coordinate.longitude == locationInfo.coordinate.longitude {
                if let image = locationInfo.image {
                    self.images.append(image)
                }
                self.comments.append(locationInfo.note)
                self.socialMediaHandles.append(locationInfo.socialMedia)
            }
        }

        self.updateImageStackView()
        self.commentsTableView.reloadData()
        
    }
    
    private func updateImageStackView() {
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for i in 0..<min(3, images.count) {
            let imageView = UIImageView()
            imageView.image = images[i]
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 8
            imageView.contentMode = .scaleAspectFill
            imageStackView.addArrangedSubview(imageView)
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        
        cell.configure(comment: comments[indexPath.row], socialMediaHandle: socialMediaHandles[indexPath.row])
        return cell
    }
}

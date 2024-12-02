//
//  CommentCell.swift
//  SoloSync
//
//  Created by Kevin Li on 11/29/24.
//
import UIKit

class CommentCell: UITableViewCell {
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    private let socialMediaLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.textColor = .systemBlue
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(commentLabel)
        containerView.addSubview(socialMediaLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        socialMediaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            commentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            commentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            socialMediaLabel.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 5),
            socialMediaLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            socialMediaLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            socialMediaLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(comment: String, socialMediaHandle: String) {
        commentLabel.text = comment
        socialMediaLabel.text = "Social: \(socialMediaHandle)"
    }
}


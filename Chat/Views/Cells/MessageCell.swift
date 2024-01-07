//
//  MessageCell.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class MessageCell: UITableViewCell {
  
  static let identifier = "MessageCell"
  
  private let stackView: UIStackView = {
    $0.spacing = 5
    return $0
  }(UIStackView())
  
  private let leftImageView: UIImageView = {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 35
    $0.layer.masksToBounds = true
    return $0
  }(UIImageView())
  
  private let rightImageView: UIImageView = {
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 35
    $0.layer.masksToBounds = true
    return $0
  }(UIImageView())
  
  private let messageLabel: UILabel = {
    $0.font = .systemFont(ofSize: 14,weight: .regular)
    $0.numberOfLines = 0
    return $0
  }(UILabel())
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setup()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setup()
    }
    
    func configure(_ item: MessageItem) {
      messageLabel.text = item.message
      setupConstraints()
      
      if item.currentUser {
        leftImageView.isHidden = true
        rightImageView.isHidden = false
        stackView.backgroundColor = .systemBlue
        rightImageView.getCachedImage(item.imageURL.absoluteString)
      } else {
        rightImageView.isHidden = true
        leftImageView.isHidden = false
        stackView.backgroundColor = .systemGray
        leftImageView.getCachedImage(item.imageURL.absoluteString)
      }
    }
    
    private func setup() {
      contentView.addSubview(stackView)
      stackView.addArrangedSubview(leftImageView)
      stackView.addArrangedSubview(messageLabel)
      stackView.addArrangedSubview(rightImageView)
      
      stackView.translatesAutoresizingMaskIntoConstraints = false
      leftImageView.translatesAutoresizingMaskIntoConstraints = false
      rightImageView.translatesAutoresizingMaskIntoConstraints = false
      messageLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
      
      NSLayoutConstraint.activate([
        stackView.topAnchor.constraint(equalTo: topAnchor),
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        
        leftImageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5),
        leftImageView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
        leftImageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
        
        messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        messageLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 5),
        messageLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -12),
        
        rightImageView.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 5),
        rightImageView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
        rightImageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
      ])
    }
}

// MARK: - MessageItem

struct MessageItem {
  let message: String
  let currentUser: Bool
  let imageURL: URL
}

//
//  MessageCell.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class MessageCell: UICollectionViewCell {
  
  static let identifier = "MessageCell"
  
  private let stackView: UIStackView = {
    $0.spacing = 5
    return $0
  }(UIStackView())
  
  private let leftImageView = AvatarView()
  
  private let rightImageView = AvatarView()
  
  private let messageLabel: UILabel = {
    $0.font = .systemFont(ofSize: 14,weight: .regular)
    $0.numberOfLines = 0
    return $0
  }(UILabel())
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  func configure(_ message: Message, item: ChatItem) {
    updateUI(using: item)
    updateMessageUI(using: message)
    setupConstraints()
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
  
  private func isCurrentUser(_ id: String) -> Bool {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return false
    }
    return DatabaseManager.shared.safeEmail(email) == id
  }
  
  private func updateMessageUI(using message: Message) {
    
    switch message.kind {
    case .photo(let media):
      guard let _ = media.url else { return }
      
    case .text(let text):
      messageLabel.text = text
      
    default: break
    }
  }
  
  private func updateUI(using item: ChatItem) {
    
    let safeEmail = DatabaseManager.shared.safeEmail(item.email)
    let filename = safeEmail + "_profile_picture.png"
    let path = "images/" + filename
    
    StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
      guard let self else { return }
      
      switch result {
      case .success(let url):
        if isCurrentUser(safeEmail) {
          rightImageView.getCachedImage(url.absoluteString)
          leftImageView.isHidden = true
          rightImageView.isHidden = false
          stackView.backgroundColor = .systemBlue
        } else {
          leftImageView.getCachedImage(url.absoluteString)
          leftImageView.isHidden = false
          rightImageView.isHidden = true
          stackView.backgroundColor = .secondarySystemBackground
        }
        
      case .failure(let error):
        print("Failed to get download url: \(error)")
      }
    })
  }
}

// MARK: - MessageItem

struct MessageItem {
  let message: String
  let currentUser: Bool
  let imageURL: URL
}

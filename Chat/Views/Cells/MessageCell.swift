//
//  MessageCell.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class MessageCell: UITableViewCell {
  
  static let identifier = "MessageCell"
  
  private let containerView: UIView = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.backgroundColor = .clear
    return $0
  }(UIView())
  
  private let senderView: UIView = {
    $0.backgroundColor = .systemBlue
    $0.translatesAutoresizingMaskIntoConstraints = false
    return $0
  }(UIView())
  
  private let receiverView: UIView = {
    $0.backgroundColor = .secondarySystemBackground
    $0.translatesAutoresizingMaskIntoConstraints = false
    return $0
  }(UIView())
  
  private let messageLabel: UILabel = {
    $0.font = .systemFont(ofSize: 14,weight: .regular)
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.numberOfLines = 0
    return $0
  }(UILabel())
  
  private let stackView: UIStackView = {
    $0.spacing = 5
    $0.axis = .horizontal
    return $0
  }(UIStackView())
  
  private let leftImageView: AvatarView = {
    $0.image = .init(systemName: "photo.circle")
    $0.translatesAutoresizingMaskIntoConstraints = false
    return $0
  }(AvatarView())
  
  private let rightImageView: AvatarView = {
    $0.image = .init(systemName: "photo.circle")
    $0.translatesAutoresizingMaskIntoConstraints = false
    return $0
  }(AvatarView())
  
  // MARK: - Init
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Configure View
  
  func configure(_ message: Message) {
    updateMessageUI(using: message)
    updateImage(using: message)
    setupViewConstraints(for: message)
  }
  
  private func setup() {
    contentView.addSubview(containerView)
    separatorInset.right = .greatestFiniteMagnitude
    backgroundColor = .clear
    
    containerView.edges(to: contentView)
    setupConstraints()
  }
  
  private func setupConstraints() {
    let padding: CGFloat = 5
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
    ])
  }
  
  // MARK: - Custom Methods
  
  private func setupViewConstraints(for item: Message) {
    let padding: CGFloat = 5
    
    if isCurrentUser(item.sender.senderId) {
      containerView.addSubview(senderView)
      senderView.addSubViews(rightImageView, messageLabel)
      
      senderView.setCornerRadius(16)
      
      NSLayoutConstraint.activate([
        rightImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
        rightImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
        rightImageView.widthAnchor.constraint(equalToConstant: 40),
        rightImageView.widthAnchor.constraint(equalToConstant: 40),
        
        senderView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
        senderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
        
        messageLabel.topAnchor.constraint(equalTo: senderView.topAnchor),
        messageLabel.bottomAnchor.constraint(equalTo: senderView.bottomAnchor),
        messageLabel.widthAnchor.constraint(equalToConstant: messageLabel.intrinsicContentSize.width + 10)
      ])
    } else {
      containerView.addSubview(receiverView)
      receiverView.addSubViews(leftImageView, messageLabel)
      
      NSLayoutConstraint.activate([
        leftImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
        leftImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
        leftImageView.widthAnchor.constraint(equalToConstant: 40),
        leftImageView.widthAnchor.constraint(equalToConstant: 40),
        
        receiverView.topAnchor.constraint(equalTo: containerView.topAnchor),
        receiverView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
        
        messageLabel.topAnchor.constraint(equalTo: receiverView.topAnchor),
        messageLabel.bottomAnchor.constraint(equalTo: receiverView.bottomAnchor),
        messageLabel.widthAnchor.constraint(equalToConstant: messageLabel.intrinsicContentSize.width + 10)
      ])
    }
  }
  
  private func isCurrentUser(_ email: String) -> Bool {
    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      return false
    }
    return DatabaseManager.shared.safeEmail(currentEmail) == email
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
  
  private func updateImage(using item: Message) {
    
    let safeEmail = item.sender.senderId
    let filename = safeEmail + "_profile_picture.png"
    let path = "images/" + filename
    
    StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
      guard let self else { return }
      
      switch result {
      case .success(let url):
        if isCurrentUser(item.sender.senderId) {
          rightImageView.getCachedImage(url.absoluteString)
        } else {
          leftImageView.getCachedImage(url.absoluteString)
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

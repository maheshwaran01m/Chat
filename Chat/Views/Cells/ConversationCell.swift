//
//  ConversationCell.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class ConversationCell: UITableViewCell {
  
  static let identifier = "ConversationCell"
  
  private lazy var userImageView: AvatarView = {
    $0.image = .init(systemName: "photo.circle")
    return $0
  }(AvatarView())
  
  private lazy var userNameLabel: UILabel = {
    $0.font = .systemFont(ofSize: 18,weight: .semibold)
    return $0
  }(UILabel())
  
  private lazy var userMessageLabel: UILabel = {
    $0.font = .systemFont(ofSize: 14,weight: .regular)
    $0.numberOfLines = 0
    return $0
  }(UILabel())
  
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    contentView.addSubview(userImageView)
    contentView.addSubview(userNameLabel)
    contentView.addSubview(userMessageLabel)
    contentView.backgroundColor = .secondarySystemBackground
    setupConstraints()
  }
  
  private func setupConstraints() {
    userImageView.translatesAutoresizingMaskIntoConstraints = false
    userNameLabel.translatesAutoresizingMaskIntoConstraints = false
    userMessageLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
      userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      userImageView.widthAnchor.constraint(equalToConstant: 40),
      userImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
      
      userNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
      userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
      userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      
      userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
      userMessageLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
      userMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      userMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
    ])
  }
  
  func configure(with model: Conversation) {
    userMessageLabel.text = model.latestMessage.text
    userNameLabel.text = model.name
    
    let safeEmail = DatabaseManager.shared.safeEmail(model.otherUserEmail)
    let path = "images/\(safeEmail)_profile_picture.png"
    
    StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
      switch result{
      case .success(let url):
        self?.userImageView.getCachedImage(url.absoluteString)
        
      case .failure(let error):
        print("Failed to get Image Url: \(error)")
      }
    })
  }
}

// MARK: - Conversation

struct Conversation {
  let id: String
  let name: String
  let otherUserEmail: String
  let latestMessage: LatestMessage
}

struct LatestMessage {
  let date: String
  let text: String
  let isRead: Bool
}

//
//  ConversationCell.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class ConversationCell: UITableViewCell {
  
  static let identifier = "ConversationCell"
  
  private lazy var userImageView: UIImageView = {
    $0.contentMode = .scaleAspectFill
    $0.layer.masksToBounds = true
    return $0
  }(UIImageView())
  
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
    setupConstraints()
  }
  
  private func setupConstraints() {
    userImageView.translatesAutoresizingMaskIntoConstraints = false
    userNameLabel.translatesAutoresizingMaskIntoConstraints = false
    userMessageLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      userImageView.widthAnchor.constraint(equalToConstant: 60),
      userImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
      
      userNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
      userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      
      userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
      userMessageLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
      userMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      userMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
    ])
    userImageView.layer.cornerRadius = userImageView.frame.height/2
  }
  
  func configure(with model: Conversation) {
    userMessageLabel.text = model.latestMessage.text
    userNameLabel.text = model.name
    
    let path = "images/\(model.otherUserEmail)_profile_picture.png"
    StorageManager.shared.downloadURL(for: path, completion: {[weak self] result in
      switch result{
      case .success(let url):
        self?.userImageView.getCachedImage(url.path())
        
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

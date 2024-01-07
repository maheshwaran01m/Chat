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
    $0.layer.cornerRadius = 35
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setupConstraints()
  }
  
  private func setupView() {
    contentView.addSubview(userImageView)
    contentView.addSubview(userNameLabel)
    contentView.addSubview(userMessageLabel)
  }
  
  private func setupConstraints() {
    userImageView.frame = CGRect(x: 10, y: 10, width: 70, height: 70)
    userNameLabel.frame = CGRect(
      x:userImageView.frame.size.width + frame.origin.x + 10, y: 10,
      width: contentView.frame.size.width - 20 - userImageView.frame.size.width,
      height: (contentView.frame.size.height-20))
    
    userMessageLabel.frame = CGRect(
      x:userImageView.frame.size.width + frame.origin.x+10,
      y: userNameLabel.frame.height + frame.origin.y + 10,
      width: contentView.frame.size.width - 20 - userImageView.frame.size.width,
      height: (contentView.frame.size.height-20))
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

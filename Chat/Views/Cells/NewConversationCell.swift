//
//  NewConversationCell.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class NewConversationCell: UITableViewCell {
  
  static let identifier = "NewConversationCell"
  
  private lazy var userImageView: AvatarView = {
    $0.setCornerRadius($0.frame.height/2)
    $0.image = .init(systemName: "photo.circle")
    return $0
  }(AvatarView())
  
  private lazy var userNameLabel: UILabel = {
    $0.font = .systemFont(ofSize: 18,weight: .semibold)
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
  }
  
  private func setupConstraints() {
    userImageView.translatesAutoresizingMaskIntoConstraints = false
    userNameLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      userImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      userImageView.widthAnchor.constraint(equalToConstant: 50),
      userImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
      
      userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
      userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
      userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
    ])
  }
}

extension NewConversationCell {
  
  func configure(with model: SearchResult) {
    userNameLabel.text = model.name
    
    let path = "images/\(model.email)_profile_picture.png"
    StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
      switch result{
      case .success(let url):
        self?.userImageView.getCachedImage(url.absoluteString)
        
      case .failure(let error):
        print("Failed to get Image Url: \(error)")
      }
    })
    setupConstraints()
  }
}

// MARK: - SearchResult

struct SearchResult {
  let name: String
  let email: String
}

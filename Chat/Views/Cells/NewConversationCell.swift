//
//  NewConversationCell.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class NewConversationCell: UITableViewCell {
  
  static let identifier = "NewConversationCell"
  
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
    userImageView.frame = CGRect(x: 10, y: 10, width: 70, height: 70)
    userNameLabel.frame = CGRect(
      x:userImageView.frame.size.width + frame.origin.x + 10, y: 10,
      width: contentView.frame.size.width - 20 - userImageView.frame.size.width,
      height: 50)
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
  }
}

// MARK: - SearchResult

struct SearchResult {
  let name: String
  let email: String
}

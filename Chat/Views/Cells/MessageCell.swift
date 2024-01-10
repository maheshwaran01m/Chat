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
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.spacing = 5
    $0.distribution = .equalSpacing
    $0.axis = .horizontal
    return $0
  }(UIStackView())
  
  private let messageLabel: UILabel = {
    $0.font = .systemFont(ofSize: 14, weight: .regular)
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.numberOfLines = 0
    return $0
  }(UILabel())
  
  // MARK: - Init
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    let clearView = UIView()
    clearView.backgroundColor = .clear
    selectedBackgroundView = clearView
  }
  
  // MARK: - Configure View
  
  func configure(_ message: Message) {
    updateMessageUI(using: message)
    setupViewConstraints(isCurrentUser(message.sender.senderId))
  }
  
  private func setup() {
    separatorInset.right = .greatestFiniteMagnitude
    backgroundColor = .clear
    setupConstraints()
  }
  
  private func setupConstraints() {
    let padding: CGFloat = 10
    
    contentView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(messageLabel)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -padding),
    ])
    stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.setCornerRadius(16)
    stackView.layer.borderWidth = 1
    stackView.layer.borderColor = UIColor.white.cgColor
    stackView.setCornerRadius(15)
  }
    
  
  // MARK: - Custom Methods
  
  private func setupViewConstraints(_ isCurrentUser: Bool) {
    let padding: CGFloat = 10
    
    if isCurrentUser {
      NSLayoutConstraint.activate([
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
      ])
      stackView.backgroundColor = .systemBlue
      messageLabel.textColor = .white
    } else {
      NSLayoutConstraint.activate([
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
      ])
      stackView.backgroundColor = .systemGroupedBackground
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
}

// MARK: - MessageItem

struct MessageItem {
  let message: String
  let currentUser: Bool
  let imageURL: URL
}

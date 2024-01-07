//
//  ChatViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class ChatViewController: UIViewController {
  
  private let tableView: UITableView = {
    $0.tableFooterView = UIView()
    return $0
  }(UITableView())
  
  private var item: ChatItem
  private var messages = [Message]()
  
  init(_ item: ChatItem) {
    self.item = item
    super.init(nibName: nil, bundle: nil)
    setupTableView()
  }
  
  required init?(coder: NSCoder) {
    self.item = .init("", name: "")
    super.init(coder: coder)
    setupTableView()
  }
}

extension ChatViewController {
  
  private func setupTableView() {
    view.addSubview(tableView)
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never
    setupConstriants()
  }
  
  private func setupConstriants() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

extension ChatViewController {
  
  private var selfSender: Sender? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return nil
    }
    let safeEmail = DatabaseManager.shared.safeEmail(email)
    
    return Sender(photURL: "", senderId: safeEmail , displayName: "Me")
  }
  
  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    formatter.locale = .current
    return formatter
  }
}

// MARK: - ChatItem

struct ChatItem {
  let email: String
  var id: String?
  let name: String
  let isNewConversation: Bool
  
  init(_ email: String, id: String? = nil, name: String, isNew: Bool = false) {
    self.email = email
    self.id = id
    self.name = name
    self.isNewConversation = isNew
  }
}

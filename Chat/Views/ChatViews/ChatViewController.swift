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
  
  init(_ item: ChatItem) {
    super.init(nibName: nil, bundle: nil)
    setupTableView()
  }
  
  required init?(coder: NSCoder) {
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

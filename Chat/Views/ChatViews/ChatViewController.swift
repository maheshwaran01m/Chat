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
  
  init(with email: String, id: String?) {
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

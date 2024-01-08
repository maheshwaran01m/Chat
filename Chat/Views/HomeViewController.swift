//
//  HomeViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class HomeViewController: UIViewController {
  
  private var viewModel = ConversationViewModel()
  
  private let tableView: UITableView = {
    $0.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
    $0.tableFooterView = UIView()
    return $0
  }(UITableView(frame: .zero, style: .insetGrouped))

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    view.backgroundColor = .systemBackground
    title = "Home"
    viewModel.delegate = self
    setupTableView()
    navigationBarButtons()
  }
}

// MARK: - TableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  
  private func setupTableView() {
    view.addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = .systemBackground
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
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.conversations.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: ConversationCell.identifier, for: indexPath) as? ConversationCell else {
      return .init()
    }
    cell.configure(with: viewModel.conversations[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    .delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                 forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else { return }
    tableView.beginUpdates()
    viewModel.deleteConversation(indexPath.row) { [weak self] in
      DispatchQueue.main.async {
        self?.tableView.deleteRows(at: [indexPath], with: .left)
        self?.tableView.endUpdates()
      }
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let item = viewModel.conversations[indexPath.row]
    let vc = ChatViewController(.init(item.otherUserEmail, id: item.id, name: item.name))
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - Add

extension HomeViewController {
  
  private func navigationBarButtons() {
    navigationItem.rightBarButtonItems = [
      .init(image: .init(systemName: "gear"), style: .done, target: self, action: #selector(profileButtonClicked)),
      .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked)),
    ]
  }
  
  @objc private func profileButtonClicked() {
    let vc = ProfileViewController()
    navigationController?.pushViewController(vc, animated: true)
  }
  
  
  @objc private func addButtonClicked() {
    let vc = NewConversationViewController { [weak self] result in
      guard let self else { return }
      
      if let conversation = self.viewModel.conversations.first(
        where: { $0.otherUserEmail == DatabaseManager.shared.safeEmail(result.email) }) {
        let vc = ChatViewController(.init(conversation.otherUserEmail, id: conversation.id, name: conversation.name))
        self.navigationController?.pushViewController(vc, animated: true)
      } else {
        createNewConversation(result)
      }
    }
    let navigation = UINavigationController(rootViewController: vc)
    present(navigation, animated: true)
  }
  
  private func createNewConversation(_ value: SearchResult) {
    let email = DatabaseManager.shared.safeEmail(value.email)
    
    DatabaseManager.shared.conversationExist(
      with: email) { [weak self] result in
        guard let self else { return }
        
        switch result {
        case .success(let id):
          let vc = ChatViewController(.init(
            email, id: id, name: value.name))
          self.navigationController?.pushViewController(vc, animated: true)
          
        case .failure:
          let vc = ChatViewController(.init(email, name: value.name, isNew: true))
          self.navigationController?.pushViewController(vc, animated: true)
        }
      }
  }
}

// MARK: - ConversationViewModelDelegate

extension HomeViewController: ConversationViewModelDelegate {
  
  func updateUI() {
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
    }
  }
}

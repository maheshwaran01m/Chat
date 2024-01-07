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
  }(UITableView())

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    view.backgroundColor = .systemBackground
    title = "Home"
    viewModel.delegate = self
    setupTableView()
    addButton()
  }
}

// MARK: - TableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  
  private func setupTableView() {
    view.addSubview(tableView)
    tableView.frame = view.bounds
    tableView.dataSource = self
    tableView.delegate = self
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
  }
}

// MARK: - Add

extension HomeViewController {
  
  private func addButton() {
    navigationItem.rightBarButtonItem = .init(
      barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
  }
  
  @objc private func addButtonClicked() {
    
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

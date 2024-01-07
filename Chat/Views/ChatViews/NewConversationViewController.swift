//
//  NewConversationViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class NewConversationViewController: UIViewController {
  
  private let tableView: UITableView = {
    $0.tableFooterView = UIView()
    $0.rowHeight = 190
    $0.isHidden = true
    return $0
  }(UITableView())
  
  private let searchBar: UISearchController = {
    $0.searchBar.placeholder = "Search Chats"
    return $0
  }(UISearchController())
  
  private let noResultsLabel: UILabel = {
    $0.isHidden = true
    $0.text = "No Results"
    $0.textAlignment = .center
    $0.textColor = .red
    $0.font = .systemFont(ofSize: 21, weight: .medium)
    return $0
  }(UILabel())
  
  private var users = [[String: String]]()
  private var records = [SearchResult]()
  private var hasFetched = false
  
  private var results: ((SearchResult) -> Void)?
  
  init(_ results: ((SearchResult) -> Void)?) {
    self.results = results
    super.init(nibName: nil, bundle: nil)
    setupTableView()
    setupSearchBar()
    setupCancelButton()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupTableView()
    setupSearchBar()
    setupCancelButton()
  }
}

// MARK: - TableView

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
  
  private func setupTableView() {
    view.addSubview(tableView)
    title = "Search"
    view.backgroundColor = .systemBackground
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
    records.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: NewConversationCell.identifier, for: indexPath) as? NewConversationCell else {
      return .init()
    }
    cell.configure(with: records[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    dismiss(animated: true) { [weak self] in
      guard let self else { return }
      self.results?(records[indexPath.row])
    }
  }
}

// MARK: - Custom Methods

extension NewConversationViewController {
  
  private func placeHolderView() {
    view.addSubview(noResultsLabel)
    NSLayoutConstraint.activate([
      noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      noResultsLabel.heightAnchor.constraint(equalToConstant: 44)
    ])
  }
  
  private func setupCancelButton() {
    navigationItem.rightBarButtonItem = .init(
      barButtonSystemItem: .cancel, target: self, action: #selector(closeButtonClicked))
  }
  
  @objc private func closeButtonClicked() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - SearchBar

extension NewConversationViewController: UISearchBarDelegate {
  
  private func setupSearchBar() {
    searchBar.searchBar.delegate = self
    navigationItem.searchController = searchBar
    searchBar.becomeFirstResponder()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text, text.isNotEmpty else {
      return
    }
    searchBar.resignFirstResponder()
    records.removeAll()
    searchUsers(for: text)
  }
  
  private func searchUsers(for value: String) {
    guard !hasFetched else {
      filterUsers(with: value)
      return
    }
    DatabaseManager.shared.getAllUsers { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let users):
        self.hasFetched = true
        self.users = users
        self.filterUsers(with: value)
      case .failure(let error):
        debugPrint("Failed to get user: \(error.localizedDescription)")
      }
    }
  }
  
  private func filterUsers(with value: String) {
    guard let currentUser = UserDefaults.standard.value(forKey: "email") as? String,
          hasFetched else {
      return
    }
    let safeEmail = DatabaseManager.shared.safeEmail(currentUser)
    
    let results: [SearchResult] = users.filter {
      guard let email = $0["email"], email != safeEmail else{
        return false
      }
      guard let name = $0["name"]?.lowercased() else{
        return false
      }
      return name.hasPrefix(value.lowercased())
    }.compactMap {
      guard let email = $0["email"] ,let name = $0["name"] else{
        return nil
      }
      return SearchResult(name: name, email: email)
    }
    records = results
    updateUI()
  }
  
  private func updateUI() {
    if records.isEmpty  {
      noResultsLabel.isHidden = false
      tableView.isHidden = true
    } else {
      noResultsLabel.isHidden = true
      tableView.isHidden = false
      tableView.reloadData()
    }
  }
}

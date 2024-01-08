//
//  ChatViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class ChatViewController: UIViewController {
  
  private var item: ChatItem
  private var messages = [Message]()
  private var collectionView: UICollectionView?
  
  init(_ item: ChatItem) {
    self.item = item
    super.init(nibName: nil, bundle: nil)
    setupCollectionView()
  }
  
  required init?(coder: NSCoder) {
    self.item = .init("", name: "")
    super.init(coder: coder)
    setupCollectionView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getMessages(for: item.id)
  }
}

extension ChatViewController {
  
  private func setupCollectionView() {
    title = item.name
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.identifier)
    view.addSubview(collectionView)
    self.collectionView = collectionView
    setupConstriants()
  }
  
  private func setupConstriants() {
    guard let collectionView else { return }
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

extension ChatViewController {
  
  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    formatter.locale = .current
    return formatter
  }
}

// MARK: - Get Messages

extension ChatViewController {
  
  private func getMessages(for id: String?) {
    guard let id else { return }
    
    DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let message):
        guard !message.isEmpty else { return }
        DispatchQueue.main.async {
          self.messages = message
          self.collectionView?.reloadData()
        }
      case .failure(let error):
        debugPrint("Failed to get messages: \(error.localizedDescription)")
      }
    }
  }
}

// MARK: - CollectionView

extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    messages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else {
      return .init()
    }
    cell.configure(messages[indexPath.row])
    return cell
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

//
//  ChatViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit
import AVKit

class ChatViewController: UIViewController {
  
  private let containerView: UIView = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.backgroundColor = .secondarySystemGroupedBackground
    $0.layer.borderColor = currentMode == .dark ? UIColor.systemBlue.cgColor : UIColor.label.cgColor
    $0.layer.borderWidth = 1
    return $0
  }(UIView())
  
  private let inputTextField: UITextField = {
    $0.returnKeyType = .send
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.font = .preferredFont(forTextStyle: .headline)
    $0.leftView = .init(frame: .init(x: 0, y: 0, width: 10, height: 0))
    return $0
  }(UITextField())
  
  private let sendButton: UIButton = {
    $0.setImage(.init(systemName: "paperplane"), for: .normal)
    $0.translatesAutoresizingMaskIntoConstraints = false
    return $0
  }(UIButton())
  
  @objc private let addButton: UIButton = {
    $0.setImage(.init(systemName: "paperclip"), for: .normal)
    $0.translatesAutoresizingMaskIntoConstraints = false
    return $0
  }(UIButton())
  
  private let tableView: UITableView = {
    $0.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
    $0.backgroundColor = .systemBackground
    return $0
  }(UITableView())
  
  private var item: ChatItem
  private var messages = [Message]()
  
  private var chatPickerVC: ChatPickerVC?
  
  init(_ item: ChatItem) {
    self.item = item
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    self.item = .init("", name: "")
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getMessages(for: item.id)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateDarkMode()
  }
}

extension ChatViewController {
  
  private func setupCollectionView() {
    title = item.name
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never
    view.addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.edges(to: view)
    setupToolbars()
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
          self.tableView.reloadData()
        }
      case .failure(let error):
        debugPrint("Failed to get messages: \(error.localizedDescription)")
      }
    }
  }
}

// MARK: - CollectionView

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: MessageCell.identifier, for: indexPath) as? MessageCell else {
      return .init()
    }
    cell.configure(messages[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    didSelectMessage(messages[indexPath.row])
  }
  
  // MARK: - Message Selection
  
  func didSelectMessage(_ message: Message) {
    switch message.kind {
      
    case .location(let location):
      let locationVC = LocationPickerVC(location.location.coordinate, title: "Location")
      navigationController?.pushViewController(locationVC, animated: true)
      
    case .photo(let media):
      guard let url = media.url else { return }
      let vc = PhotoViewController(url)
      navigationController?.pushViewController(vc, animated: true)
      
    case .video(let media):
      guard let url = media.url else { return }
      let vc = AVPlayerViewController()
      vc.player = .init(url: url)
      vc.allowsPictureInPicturePlayback = true
      present(vc, animated: true)
      
    default: break
    }
  }
}

// MARK: - ChatItem

struct ChatItem {
  let email: String
  var id: String?
  let name: String
  var isNewConversation: Bool
  
  init(_ email: String, id: String? = nil, name: String, isNew: Bool = false) {
    self.email = email
    self.id = id
    self.name = name
    self.isNewConversation = isNew
  }
}

extension ChatViewController {
  
  private func setupToolbars() {
    view.addSubview(containerView)
    containerView.addSubViews(inputTextField, sendButton, addButton)
    
    inputTextField.placeholder = "Chat with \(item.name)"
    inputTextField.delegate = self
    containerView.setCornerRadius(25)
    
    sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
    addButton.addTarget(self, action: #selector(presentChatPickerVC), for: .touchUpInside)
    
    let padding: CGFloat = 10
    
    NSLayoutConstraint.activate([
      containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      containerView.heightAnchor.constraint(equalToConstant: 50),
      
      inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      inputTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
      inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor),
      
      sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      sendButton.leadingAnchor.constraint(equalTo: inputTextField.trailingAnchor, constant: padding),
      sendButton.centerYAnchor.constraint(equalTo: inputTextField.centerYAnchor),
      sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor),
      
      addButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      addButton.leadingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: padding),
      addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
      addButton.centerYAnchor.constraint(equalTo: inputTextField.centerYAnchor),
      addButton.heightAnchor.constraint(equalTo: containerView.heightAnchor),
    ])
  }
  
  private func updateDarkMode() {
    containerView.layer.borderColor = currentMode == .dark ? UIColor.white.cgColor : UIColor.label.cgColor
  }
}

extension ChatViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    sendMessageToFirebase()
    return true
  }
  
  @objc private func sendButtonClicked() {
    sendMessageToFirebase()
  }
}

// MARK: - MessageID

extension ChatViewController {
  
  private var createMessageID: String? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return nil
    }
    let dateString = dateFormatter.string(from: Date())
    let safeCurrentEmail = DatabaseManager.shared.safeEmail(email)
    
    let newIdentifier = "\(item.email)_\(safeCurrentEmail)_\(dateString)"
    return newIdentifier
  }
  
  private var currentUser: SenderType? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return nil
    }
    let safeEmail = DatabaseManager.shared.safeEmail(email)
    
    return SenderType(senderId: safeEmail, displayName: "Me")
  }
}

// MARK: - Send Message

extension ChatViewController {
  
  private func sendMessageToFirebase() {
    guard let text = inputTextField.text, text.isNotEmpty,
          let currentUser, let createMessageID else {
      return
    }
    let message = Message(sender: currentUser, messageId: createMessageID, sentDate: Date(), kind: .text(text))
    
    guard item.isNewConversation else {
      DatabaseManager.shared.sendMessage(
        to: item.id ?? "",
        otherUserEmail: item.email,
        name: item.name,
        newMessage: message) { [weak self] created in
          guard let self, created else {
            debugPrint("Failed to send text message")
            return
          }
          self.inputTextField.text = nil
        }
      return
    }
    DatabaseManager.shared.createNewConversation(
      with: item.email, name: item.name,
      firstMessage: message) { [weak self] created in
        guard let self, created else {
          debugPrint("Failed to send text message")
          return
        }
        self.item.isNewConversation = false
        let newConversationId = "conversation_\(message.messageId)"
        self.item.id = newConversationId
        self.getMessages(for: newConversationId)
        self.inputTextField.text = nil
      }
  }
}

// MARK: - Attachments

extension ChatViewController: ChatPickerDelegate {
  
  @objc private func presentChatPickerVC(_ button: UIButton) {
    let picker = ChatPickerVC()
    picker.delegate = self
    picker.presentPickerVC(self, for: button)
    self.chatPickerVC = picker
  }
  
  func selectedImage(_ image: UIImage) {
    guard let currentUser, let createMessageID, let id = item.id, let data = image.pngData() else { return }
    let fileName = "photo_message_" + createMessageID.replacingOccurrences(of: " ", with: "-") + ".png"
    
    StorageManager.shared.uploadMessagePhoto(with: data, fileName: fileName) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let urlString):
        guard let url = URL(string: urlString),
              let placeholder = UIImage(systemName: "paperplane") else{
          return
        }
        let message = Message(
          sender: currentUser,
          messageId: createMessageID,
          sentDate: Date(),
          kind: .photo(.init(url: url, image: nil, placeholderImage: placeholder, size: .zero)))
        
        DatabaseManager.shared.sendMessage(
          to: id,
          otherUserEmail: item.email,
          name: item.name,
          newMessage: message) { [weak self] created in
            guard let self, created else {
              debugPrint("Failed to send photo message")
              return
            }
            self.item.isNewConversation = false
            let newConversationId = "conversation_\(message.messageId)"
            self.item.id = newConversationId
            self.getMessages(for: newConversationId)
            self.inputTextField.text = nil
          }
        
      case .failure(let error):
        debugPrint("Failed to send photo message \(error.localizedDescription)")
      }
    }
  }
  
  func selectedVideoURL(_ url: URL) {
    
    guard let currentUser, let createMessageID, let id = item.id else { return }
    let fileName = "photo_message_" + createMessageID.replacingOccurrences(of: " ", with: "-") + ".mov"
    
    StorageManager.shared.uploadMessageVideo(with: url, fileName: fileName) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let urlString):
        guard let url = URL(string: urlString),
              let placeholder = UIImage(systemName: "paperplane") else{
          return
        }
        let message = Message(
          sender: currentUser,
          messageId: createMessageID,
          sentDate: Date(),
          kind: .video(.init(url: url, image: nil, placeholderImage: placeholder, size: .zero)))
        
        DatabaseManager.shared.sendMessage(
          to: id,
          otherUserEmail: item.email,
          name: item.name,
          newMessage: message) { [weak self] created in
            guard let self, created else {
              debugPrint("Failed to send video message")
              return
            }
            self.item.isNewConversation = false
            let newConversationId = "conversation_\(message.messageId)"
            self.item.id = newConversationId
            self.getMessages(for: newConversationId)
            self.inputTextField.text = nil
          }
        
      case .failure(let error):
        debugPrint("Failed to send video message \(error.localizedDescription)")
      }
    }
  }
  
  func selectedLocationCoordinates(_ latitude: Double, longitude: Double) {
    guard let currentUser, let createMessageID, let id = item.id else { return }
    
    let location = Location(location: .init(latitude: latitude, longitude: longitude), size: .zero)
    let message = Message(
      sender: currentUser,
      messageId: createMessageID,
      sentDate: Date(),
      kind: .location(location))
    
    DatabaseManager.shared.sendMessage(
      to: id,
      otherUserEmail: item.email,
      name: item.name,
      newMessage: message) { [weak self] created in
        guard let self, created else {
          debugPrint("Failed to send location message")
          return
        }
        self.item.isNewConversation = false
        let newConversationId = "conversation_\(message.messageId)"
        self.item.id = newConversationId
        self.getMessages(for: newConversationId)
        self.inputTextField.text = nil
      }
  }
}

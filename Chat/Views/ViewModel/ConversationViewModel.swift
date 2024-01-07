//
//  ConversationViewModel.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

protocol ConversationViewModelDelegate: AnyObject {
  
  func updateUI()
}

class ConversationViewModel {
  
  var conversations = [Conversation]()
  
  weak var delegate: ConversationViewModelDelegate?
  
  
  init() {
    getConversations()
  }
}

extension ConversationViewModel {
  
  func getConversations() {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
        return
    }
    DatabaseManager.shared.getAllConversations(for: email) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let conversations):
        self.conversations = conversations
        delegate?.updateUI()
        
      case .failure(let error):
        print("Error \(error.localizedDescription)")
      }
    }
  }
}

extension ConversationViewModel {
  
  func deleteConversation(_ index: Int, completion: @escaping () -> Void) {
    DatabaseManager.shared.deleteConversation(
      conversationId: conversations[index].id) { [weak self] deleted in
        guard deleted else {
          debugPrint("Failed to delete")
          completion()
          return
        }
        self?.conversations.remove(at: index)
        completion()
    }
  }
}

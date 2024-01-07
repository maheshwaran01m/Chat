//
//  DatabaseManager.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class DatabaseManager {
  
  static let shared = DatabaseManager()
  private init() {}
  
  private let manager = Database.database().reference()
}

// MARK: - Existing User

extension DatabaseManager {
  
  func userExists(for email: String, completion: @escaping (Bool) -> Void) {
    manager.child(email).observeSingleEvent(of: .value) { snapshot in
      guard snapshot.value as? [String: Any] != nil else {
        completion(false)
        return
      }
      completion(true)
    }
  }
}

// MARK: - New User

struct User {
  let firstName: String
  let lastName: String
  let emailAddress: String
  let password: String
  let profileImage: Data?
  
  var profileImageName: String {
    "\(emailAddress)_profile_picture.png"
  }
  
  var safeEmail: String {
    var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
}

extension DatabaseManager {
  
  func safeEmail(_ emailAddress: String) -> String {
    var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
  
  func checkAndCreateUser(for user: User, completion: @escaping (String?) -> Void) {
    userExists(for: user.safeEmail) { exist in
      
      guard !exist else {
        completion("Looks Like User already exist for this email address")
        return
      }
      
      FirebaseAuth.Auth.auth().createUser(
        withEmail: user.emailAddress,
        password: user.password) { [weak self] result, error in
          
          guard let self, error == nil else {
            completion("Unable to create new user, try again!")
            return
          }
          
          guard let result, let email = result.user.email, email.isNotEmpty else {
            return
          }
          
          self.createUser(for: user) { error in
            guard error == nil else {
              completion(error)
              return
            }
          }
          // store image
          UserDefaults.standard.setValue(email, forKey: "email")
          UserDefaults.standard.setValue("\(user.firstName) \(user.lastName)", forKey: "name")
          
          if let imageData = user.profileImage {
            StorageManager.shared.uploadProfilePicture(
              with: imageData, fileName: user.profileImageName) { result in
                switch result {
                case.success((let downloadUrl)):
                  UserDefaults.standard.set(downloadUrl,forKey: "profile_picture_url")
                  
                case .failure(let error):
                  print("Storage Manager error: \(error)")
                }
              }
          }
          
          completion(nil)
        }
    }
  }
  
  private func createUser(for user: User, completion: @escaping (String?) -> Void) {
    manager.child(user.safeEmail)
      .setValue(["first_name": user.firstName, "last_name": user.lastName]) { [weak self] error, _ in
        guard let self, error == nil else {
          completion("Failed to write to databse")
          return
        }
        
        manager.child("Users")
          .observeSingleEvent(of: .value) { snapshot in
            
            guard var usersCollection = snapshot.value as? [[String: String]] else {
              
              let newCollection = ["name": user.firstName + " " + user.lastName, "email": user.safeEmail]
              
              self.manager.child("users")
                .setValue(newCollection) { error, _ in
                  guard error == nil else {
                    completion(error?.localizedDescription)
                    return
                  }
                  completion(nil)
                }
              
              return
            }
            let newCollection = ["name": user.firstName + " " + user.lastName, "email": user.safeEmail]
            usersCollection.append(newCollection)
            
            self.manager.child("users")
              .setValue(usersCollection) { error, _ in
                guard error == nil else {
                  completion(error?.localizedDescription)
                  return
                }
                completion(nil)
              }
            
          }
      }
  }
}

// MARK: - Sign In

extension DatabaseManager {
  
  func signIn(for email: String, password: String, completion: @escaping (String?) -> Void) {
    FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
      guard let self else { return }
      
      guard error == nil, let result else {
        completion("Failed to Login")
        debugPrint("Login Error: \(error?.localizedDescription ?? "")")
        return
      }
      let safeEmail = safeEmail(email)
      
      manager.child(safeEmail)
        .observeSingleEvent(of: .value) { snapshot in
          guard let value = snapshot.value else {
            completion("Failed to Login for email: \(email)")
            return
          }
          guard let userData = value as? [String: Any],
                let firstName = userData["first_name"] as? String,
                let lastName = userData["last_name"] as? String else {
            return
          }
          UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
          UserDefaults.standard.set(email, forKey: "email")
          
          debugPrint("Logged In: \(result.user)")
          completion(nil)
        }
    }
  }
}

// MARK: - Get

extension DatabaseManager {
  
  func getAllConversations(for email: String,
                           completion: @escaping (Result<[Conversation], Error>) -> Void) {
    
    manager.child("\(safeEmail(email))/conversations").observe(.value, with: { snapshot in
      
      guard let value = snapshot.value as? [[String: Any]] else{
        completion(.failure(URLError(.downloadDecodingFailedToComplete)))
        return
      }
      let conversations: [Conversation] = value.compactMap { dictionary in
        guard let conversationId = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let otherUserEmail = dictionary["other_user_email"] as? String,
              let latestMessage = dictionary["latest_message"] as? [String: Any],
              let date = latestMessage["date"] as? String,
              let message = latestMessage["message"] as? String,
              let isRead = latestMessage["is_read"] as? Bool else{
          
          return nil
        }
        let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
        
        return .init(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
      }
      completion(.success(conversations))
    })
  }
}

// MARK: - Search

extension DatabaseManager {
  
  func conversationExist(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>)-> Void){
      
      let safeRecipientEmail = safeEmail(targetRecipientEmail)
      guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
          return
      }
      let safeSenderEmail = safeEmail(senderEmail)
      
      manager.child("\(safeRecipientEmail)").observeSingleEvent(of: .value, with: { snapshot in
          guard let collection = snapshot.value as? [[String: Any]] else {
            completion(.failure(URLError(.cancelled)))
              return
          }
          
          //iterate and find conversation with target
          if let conversation = collection.first(where: {
              guard let targetSenderEmail = $0["other_user_email"] as? String else{
                  return false
              }
              return safeSenderEmail == targetSenderEmail
          }){
             //get id
              guard let id = conversation["id"] as? String else {
                  completion(.failure(URLError(.cancelled)))
                  return
              }
              completion(.success(id))
              return
          }
          completion(.failure(URLError(.cancelled)))
          return
      })
  }
}

// MARK: - Delete

extension DatabaseManager {
  
  func deleteConversation(conversationId: String, completion: @escaping(Bool) -> Void) {
    
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return
    }
    let safeEmail = safeEmail(email)
    
    debugPrint("Deleting Conversation with id: \(conversationId)")
    
    let ref = manager.child("\(safeEmail)/conversations")
    
    ref.observeSingleEvent(of: .value, with: { snapshot in
      if var conversations = snapshot.value as? [[String: Any]] {
        var positionToRemove = 0
        
        for conversation in conversations {
          if let id = conversation["id"] as? String,
             id == conversationId {
            debugPrint("Found conversation to delete")
            break
          }
          positionToRemove += 1
        }
        
        conversations.remove(at: positionToRemove)
        ref.setValue(conversations, withCompletionBlock: { error,_ in
          guard error == nil else{
            completion(false)
            debugPrint("Failed to delete")
            return
          }
          
          completion(true)
        })
      }
    })
  }
}

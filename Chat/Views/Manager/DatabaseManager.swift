//
//  DatabaseManager.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import UIKit

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

// MARK: - Get Users

extension DatabaseManager {
  
  func getAllUsers(_ completion: @escaping (Result<[[String: String]], Error>) -> Void) {
    manager.child("users").observeSingleEvent(of: .value, with: { snapshot in
      guard let value = snapshot.value as? [[String: String]] else {
        completion(.failure(DatabaseError.failedToFetch))
        return
      }
      completion(.success(value))
    })
  }
  
  enum DatabaseError: Error {
    case failedToFetch
  }
}

// MARK: - Send

extension DatabaseManager {
  
  func sendMessage(to conversation: String, otherUserEmail: String, name: String,
                   newMessage: Message, completion: @escaping (Bool) -> Void) {
    
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      completion(false)
      return
    }
    let currentEmail = safeEmail(email)
    
    manager.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
      
      guard let self, var currentMessages = snapshot.value as? [[String: Any]] else{
        completion(false)
        return
      }
      
      let messageDate = newMessage.sentDate
      let dateString = dateFormatter.string(from: messageDate)
      
      var message = ""
      
      switch newMessage.kind {
        
      case .text(let messageText):
        message = messageText
        
      case .photo(let mediaItem):
        if let targetUrlString = mediaItem.url?.absoluteString{
          message = targetUrlString
        }
        break
      case .video(let mediaItem):
        if let targetUrlString = mediaItem.url?.absoluteString{
          message = targetUrlString
        }
        
        break
      case .location(let locationData):
        let location = locationData.location
        message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
        break
      case .emoji(_):
        break
      }
      guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else{
        completion(false)
        return
      }
      
      let currentUserEmail = safeEmail(email)
      
      let newMessageEntry: [String: Any] = [
        "id": newMessage.messageId,
        "type": newMessage.kind.description,
        "content": message ,
        "date": dateString,
        "sender_email": currentUserEmail,
        "is_read": false,
        "name": name
      ]
      currentMessages.append(newMessageEntry)
      
      self.manager.child("\(conversation)/messages").setValue(currentMessages){ error, _ in
        guard error == nil else {
          
          completion(false)
          return
        }
        self.manager.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
          
          var databaseEntryConversations = [[String: Any]]()
          
          let updatedValue:[String: Any] = [
            "date": dateString,
            "is_read": false,
            "message": message,
          ]
          
          if var currentUserConversations = snapshot.value as? [[String: Any]] {
            
            var targetCoversation: [String:Any]?
            var position = 0
            for conversationDictionary in currentUserConversations {
              if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                targetCoversation = conversationDictionary
                break
              }
              position += 1
            }
            
            if var targetConversation = targetCoversation {
              
              targetConversation["latest_message"] = updatedValue
              
              currentUserConversations[position] = targetConversation
              databaseEntryConversations = currentUserConversations
            }
            else {
              let newConversationData: [String: Any] = [
                "id": conversation,
                "other_user_email":  self.safeEmail(otherUserEmail),
                "name": name,
                "latest_message": updatedValue
              ]
              
              currentUserConversations.append(newConversationData)
              databaseEntryConversations = currentUserConversations
            }
            
          } else {
            let newConversationData: [String: Any] = [
              "id": conversation,
              "other_user_email":  self.safeEmail(otherUserEmail),
              "name": name,
              "latest_message": updatedValue
            ]
            
            databaseEntryConversations = [
              newConversationData
            ]
          }
          
          
          self.manager.child("\(currentEmail)/conversations").setValue(
            databaseEntryConversations, withCompletionBlock: { error, _ in
              guard error == nil else{
                completion(false)
                return
              }
              
              self.manager.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                
                //find conversation id in database
                //array
                let updatedValue:[String: Any] = [
                  "date": dateString,
                  "is_read": false,
                  "message": message,
                ]
                
                var databaseEntryConversations = [[String: Any]]()
                guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                  return
                }
                
                if var otherUserConversations = snapshot.value as? [[String: Any]] {
                  
                  
                  //dictionary
                  var targetCoversation: [String:Any]?
                  var position = 0
                  for conversationDictionary in otherUserConversations {
                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                      targetCoversation = conversationDictionary
                      break
                    }
                    position += 1
                  }
                  if var targetCoversation = targetCoversation {
                    targetCoversation["latest_message"] = updatedValue
                    
                    otherUserConversations[position] = targetCoversation
                    databaseEntryConversations = otherUserConversations
                  }
                  else{
                    //failed to find in current collection
                    //new conversation
                    let newConversationData: [String: Any] = [
                      "id": conversation,
                      "other_user_email":  self.safeEmail(otherUserEmail),
                      "name": currentName,
                      "latest_message": updatedValue
                    ]
                    
                    otherUserConversations.append(newConversationData)
                    databaseEntryConversations = otherUserConversations
                  }
                  
                } else {
                  //current conversation does not exist
                  //new conversation
                  let newConversationData: [String: Any] = [
                    "id": conversation,
                    "other_user_email": self.safeEmail(currentEmail),
                    "name": currentName,
                    "latest_message": updatedValue
                  ]
                  
                  databaseEntryConversations = [
                    newConversationData
                  ]
                }
                
                
                self.manager.child("\(otherUserEmail)/conversations").setValue(
                  databaseEntryConversations, withCompletionBlock: { error, _ in
                    guard error == nil else{
                      completion(false)
                      return
                    }
                    completion(true)
                  })
              })
            })
        })
      }
    })
  }
}

struct Message {
  var sender: SenderType
  var messageId: String
  var sentDate: Date
  var kind: MessageKind
}

struct SenderType {
  var senderId: String
  var displayName: String
}

enum MessageKind {
  case text(String), photo(Media), video(Media),
       location(Location), emoji(String)
  
  var description: String {
    switch self {
    case .text: return "text"
    case .photo: return "photo"
    case .video: return "video"
    case .location: return "location"
    case .emoji: return "emoji"
    }
  }
}

struct Sender {
  var photURL: String
  var senderId: String
  var displayName: String
}

struct Media {
  var url: URL?
  var image: UIImage?
  var placeholderImage: UIImage
  var size: CGSize
}

struct Location {
  var location: CLLocation
  var size: CGSize
}

// MARK: - Formatter

extension DatabaseManager {
  
  var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    formatter.locale = .current
    return formatter
  }
}

// MARK: - Create Conversation

extension DatabaseManager {
  
  func createNewConversation(with otherUserEmail: String,name: String,
                             firstMessage: Message, completion: @escaping (Bool) -> Void) {
    
    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
          let currentNamme = UserDefaults.standard.value(forKey: "name") as? String else {
      return
    }
    
    let safeEmail = safeEmail(currentEmail)
    let ref = manager.child("\(safeEmail)")
    
    ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
      guard let self, var userNode = snapshot.value as? [String: Any] else {
        completion(false)
        print("user not Found")
        return
      }
      //array
      let messageDate = firstMessage.sentDate
      let dateString = dateFormatter.string(from: messageDate)
      
      var message = ""
      
      switch firstMessage.kind {
        
      case .text(let messageText):
        message = messageText
        
      case .photo(_):
        break
      case .video(_):
        break
      case .location(_):
        break
      case .emoji(_):
        break
      }
      let conversationId = "conversation_\(firstMessage.messageId)"
      
      //new conversation
      let newConversationData: [String: Any] = [
        "id": conversationId,
        "other_user_email": otherUserEmail,
        "name": name,
        "latest_message": [
          "date": dateString,
          "message": message,
          "is_read": false
        ]
      ]
      
      //recipient
      let recipient_newConversationData: [String: Any] = [
        
        "id": conversationId,
        "other_user_email": safeEmail,
        "name": currentNamme,
        "latest_message": [
          "date": dateString,
          "message": message,
          "is_read": false
        ]
      ]
      //update recipient conversation
      self.manager.child("\(otherUserEmail)/conversations").observeSingleEvent(
        of: .value, with: { [weak self] snapshot in
          if var conversations = snapshot.value as? [[String: Any]] {
            //append
            conversations.append(recipient_newConversationData)
            self?.manager.child("\(otherUserEmail)/conversations").setValue(newConversationData)
          }
          else{
            //create
            self?.manager.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
          }
        })
      
      
      //update current user conversation entry
      if var conversations = userNode ["conversations"] as? [[String: Any]]{
        //conversation array exists
        conversations.append(newConversationData)
        userNode["conversations"] = conversations
        ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
          
          guard error == nil else {
            completion(false)
            return
          }
          self?.finishCreatingCoversation(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
          //completion(true)
        })
        
      } else {
        //conversation does not exists
        userNode["conversations"] = [
          newConversationData
        ]
        ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
          
          guard error == nil else {
            completion(false)
            return
          }
          self?.finishCreatingCoversation(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
          //completion(true)
        })
      }
    })
  }
  
  private func finishCreatingCoversation(name: String, conversationID: String, firstMessage: Message,
                                         completion: @escaping (Bool) -> Void){
    
    //date
    let messageDate = firstMessage.sentDate
    let dateString = dateFormatter.string(from: messageDate)
    
    //content
    var message = ""
    
    switch firstMessage.kind {
      
    case .text(let messageText):
      message = messageText
    case .photo(_):
      break
    case .video(_):
      break
    case .location(_):
      break
    case .emoji(_):
      break
    }
    //sender email
    guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else{
      completion(false)
      return
    }
    let currentUserEmail = safeEmail(myEmmail)
    
    let collectionMessage: [String: Any] = [
      "id": firstMessage.messageId,
      "type": firstMessage.kind.description,
      "content": message ,
      "date": dateString,
      "sender_email": currentUserEmail,
      "is_read": false,
      "name": name
    ]
    let value: [String: Any] = [
      "messages": [
        collectionMessage
      ]
    ]
    debugPrint("adding convo:\(conversationID)")
    
    manager.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
      guard error == nil else {
        completion(false)
        return
      }
      completion(true)
    })
  }
}

// MARK: - Message For Conversation

extension DatabaseManager {
  
  func getAllMessagesForConversation(
    with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
      
      manager.child("\(id)/messages").observe(.value, with: { [weak self] snapshot in
        
        guard let self, let value = snapshot.value as? [[String: Any]] else{
          completion(.failure(DatabaseError.failedToFetch))
          return
        }
        
        let messages: [Message] = value.compactMap { dictionary in
          
          guard let name = dictionary["name"] as? String,
                let isRead = dictionary["is_read"] as? Bool,
                let messageID = dictionary["id"] as? String,
                let content = dictionary["content"] as? String,
                let senderEmail = dictionary["sender_email"] as? String,
                let dateString = dictionary["date"] as? String,
                let type = dictionary["type"] as? String,
                //date
                let date = self.dateFormatter.date(from: dateString) else {
            return nil
          }
          
          var kind: MessageKind?

          if type == "photo" {
            
            guard let imageUrl = URL(string: content), let placeholder = UIImage(systemName: "plus") else{
              return nil
            }
            let media = Media(url: imageUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
            kind = .photo(media)
          } else if type == "video" {

            guard let videoUrl = URL(string: content), let placeholder = UIImage(named: "video_placeholder") else{
              return nil
            }
            let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
            kind = .video(media)
          } else if type == "location" {
            
            let locationComponents = content.components(separatedBy: ",")
            guard let longitude = Double(locationComponents[0]),
                  let latitude = Double(locationComponents[1]) else {
              return nil
            }
            print("Rendering location: long=\(longitude) | lat=\(latitude)")
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                    size: CGSize(width: 300, height: 300))
            kind = .location(location)
          } else {
            kind = .text(content)
          }
          guard let finalKind = kind else {
            return nil
          }
          let sender = SenderType(senderId: senderEmail, displayName: name)
          
          return Message(sender: sender, messageId: messageID, sentDate: date, kind: finalKind)
        }
        
        completion(.success(messages))
      })
    }
}

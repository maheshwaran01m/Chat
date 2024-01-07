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
  
  static func safeEmail(_ emailAddress: String) -> String {
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

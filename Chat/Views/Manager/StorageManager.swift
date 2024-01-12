//
//  StorageManager.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import Foundation
import FirebaseStorage

final class StorageManager {
  
  static let shared = StorageManager()
  
  private init() {}
  
  private let storage = Storage.storage().reference()
  
  typealias UploadPictureCompletion = (Result<String, Error>) -> Void
  
  ///uploads picture to firebase storage and returns compeltion to url string to download
  func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
    
    storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
      guard let strongSelf = self else {
        return
      }
      guard error == nil else{
        //failed
        print("failed to upload data to database")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }
      strongSelf.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
        guard let url = url else {
          print("Failed to get download url")
          completion(.failure(StorageErrors.failedToGetDownloadUrl))
          return
        }
        let urlString = url.absoluteString
        print("download url returned: \(urlString)")
        completion(.success(urlString))
      })
    })
  }
  
  func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
    storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
      guard error == nil else{
        //failed
        print("failed to upload data to database")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }
      self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
        guard let url = url else {
          print("Failed to get download url")
          completion(.failure(StorageErrors.failedToGetDownloadUrl))
          return
        }
        let urlString = url.absoluteString
        print("download url returned: \(urlString)")
        completion(.success(urlString))
      })
    })
    
  }
  
  func uploadMessageVideo(with fileurl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
    storage.child("message_videos/\(fileName)").putFile(from: fileurl, metadata: nil, completion: { [weak self] metadata, error in
      guard error == nil else{
        print("failed to upload Video file  to firebase database")
        completion(.failure(StorageErrors.failedToUpload))
        return
      }
      
      self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
        guard let url = url else {
          print("Failed to get download url")
          completion(.failure(StorageErrors.failedToGetDownloadUrl))
          return
        }
        let urlString = url.absoluteString
        print("download url returned: \(urlString)")
        completion(.success(urlString))
      })
    })
    
  }
}

// MARK: - StorageErrors

extension StorageManager {
  
  enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadUrl
  }
  
  func downloadURL(for path: String, completion:@escaping (Result<URL, Error>) -> Void){
    let reference = storage.child(path)
    reference.downloadURL(completion: { url, error in
      guard let url = url, error == nil else {
        completion(.failure(StorageErrors.failedToGetDownloadUrl))
        return
      }
      completion(.success(url))
    })
  }
}

//
//  CacheManager.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

public final class CacheManager {
  
  public static let shared = CacheManager()
  
  private init() {}
  
  private let imageCache = NSCache<NSString, UIImage>()
}

extension CacheManager {
  
  public func downloadImage(_ urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
    
    let cacheKey = NSString(string: urlString)
    
    if let image = imageCache.object(forKey: cacheKey) {
      completion(.success(image))
    } else {
      
      guard let url = URL(string: urlString) else { return }
      
      URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        guard let self, error == nil else {
          completion(.failure(URLError(.badServerResponse)))
          return
        }
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
          completion(.failure(URLError(.badServerResponse)))
          return
        }
        guard let data, let image = UIImage(data: data) else {
          completion(.failure(URLError(.dataNotAllowed)))
          return
        }
        // cache image
        imageCache.setObject(image, forKey: cacheKey)
        
        completion(.success(image))
      }.resume()
    }
  }
}

// MARK: - Get

public extension CacheManager {
  
  func getValue(_ key: String) -> UIImage? {
    guard let image = imageCache.object(forKey: cacheKey(key)) else { return nil }
    return image
  }
  
  func contains(_ key: String) -> Bool {
    return getValue(key) != nil
  }
  
  private func cacheKey(_ key: String) -> NSString {
    NSString(string: key)
  }
}

// MARK: - Clear Cache

public extension CacheManager {
  
  func clearImageCache() {
    imageCache.removeAllObjects()
  }
  
  func clearImageCache(forKey key: String) {
    imageCache.removeObject(forKey: cacheKey(key))
  }
}

// MARK: - Cached Image

extension UIImageView {
  
  public func getCachedImage(_ urlString: String?) {
    guard let urlString else { return }
    
    CacheManager.shared.downloadImage(urlString) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let image):
        DispatchQueue.main.async {
          self.image = image
        }
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
}

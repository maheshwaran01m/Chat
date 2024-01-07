//
//  AlertVC.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

extension UIViewController {
  
  func showAlert(_ title: String, message: String?, button: String = "Ok") {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
    
    let buttonAction = UIAlertAction(title: button, style: .default) { [weak self] _ in
      self?.dismiss(animated: true)
    }
    alert.addAction(buttonAction)
    alert.preferredAction = buttonAction
    
    present(alert, animated: true)
  }
}

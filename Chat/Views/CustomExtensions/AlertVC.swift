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
    
    let buttonAction = UIAlertAction(title: button, style: .default) { _ in
      alert.dismiss(animated: true)
    }
    alert.addAction(buttonAction)
    alert.preferredAction = buttonAction
    
    if let popOver = alert.popoverPresentationController {
      self.modalPresentationStyle = .popover
      popOver.sourceView = view
      popOver.sourceRect = CGRect(x: view.bounds.midX,
                                  y: view.bounds.midY,
                                  width: 0, height: 0)
    }
    present(alert, animated: true)
  }
}

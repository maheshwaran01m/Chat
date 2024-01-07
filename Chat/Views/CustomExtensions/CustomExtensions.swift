//
//  CustomExtensions.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

extension UIViewController {
  
  func resignFirstResponderForView(_ views: UIView...) {
    for view in views {
      view.resignFirstResponder()
    }
  }
}

extension UIView {
  
  func addSubViews(_ views: UIView...) {
    for view in views {
      view.translatesAutoresizingMaskIntoConstraints = false
      addSubview(view)
    }
  }
}

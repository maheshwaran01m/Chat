//
//  CustomExtensions.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

var currentMode: UIUserInterfaceStyle {
  UITraitCollection.current.userInterfaceStyle
}

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
  
  func setCornerRadius(_ radius: CGFloat? = nil) {
    guard let radius else {
      let cornerRadius = min(frame.width, frame.height)
      layer.cornerRadius = cornerRadius/2
      layer.masksToBounds = true
      return
    }
    layer.cornerRadius = radius
    layer.masksToBounds = true
  }
}

extension UIView {
  
  func edges(to superView: UIView) {
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor),
      leadingAnchor.constraint(equalTo: superView.leadingAnchor),
      trailingAnchor.constraint(equalTo: superView.trailingAnchor),
      bottomAnchor.constraint(equalTo: superView.bottomAnchor),
    ])
  }
}

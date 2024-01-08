//
//  AvatarView.swift
//  Chat
//
//  Created by MAHESHWARAN on 08/01/24.
//

import UIKit

class AvatarView: UIImageView {
  
  override var frame: CGRect {
    didSet {
      setCornerRadius()
    }
  }
  
  override var bounds: CGRect {
    didSet {
      setCornerRadius()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  init() {
    super.init(frame: .zero)
    setupView()
  }
  
  private func setupView() {
    layer.masksToBounds = true
    clipsToBounds = true
    contentMode = .scaleAspectFill
    setCornerRadius()
  }
}

//
//  PhotoViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

class PhotoViewController: UIViewController {
  
  private let url: URL?
  
  private lazy var imageView: UIImageView = {
    $0.contentMode = .scaleAspectFit
    $0.layer.masksToBounds = true
    return $0
  }(UIImageView())
  
  init(_ url: URL?) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    url = .init(string: "")
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    view.backgroundColor = .systemBackground
    title = "Photo"
    navigationItem.largeTitleDisplayMode = .never
    view.addSubview(imageView)
    imageView.getCachedImage(url?.absoluteString)
    setupConstraints()
  }
  
  private func setupConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
}

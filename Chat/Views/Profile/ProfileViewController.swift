//
//  ProfileViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
  
  private var records = [ProfileModel]()
  
  private let tableView: UITableView = {
    $0.tableFooterView = UIView()
    $0.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
    return $0
  }(UITableView())
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    view.backgroundColor = .systemBackground
    title = "Profile"
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
    tableView.tableHeaderView = profileImageView
    setupConstriants()
    setupRecords()
  }
  
  private func setupConstriants() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
  
  private func setupRecords() {
    let name = "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")"
    records.append(.init(.info, title: name))
    
    let email = "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")"
    records.append(.init(.info, title: email))
    
    records.append(.init(.logout, title: "Sign Out") { [weak self] in
      self?.signOut()
    })
  }
}

// MARK: - Profile Image

extension ProfileViewController {
  
  private var profileImageView: UIView? {
    let headerView = UIView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 150))
    headerView.backgroundColor = .systemBackground
    headerView.addSubview(getProfileImage)
    
    return headerView
  }
  
  private var getProfileImage: UIImageView {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return UIImageView(frame: .zero)
    }
    let safeEmail = DatabaseManager.shared.safeEmail(email)
    let path = "images/" + safeEmail + "_profile_picture.png"
    
    let imageView = UIImageView(
      frame: .init(x: view.frame.width/3-10,
                   y: 0, width: view.frame.width/3, height: view.frame.width/3))
    imageView.contentMode = .scaleAspectFill
    imageView.image = .init(systemName: "person.circle")
    imageView.layer.borderColor = UIColor.white.cgColor
    imageView.layer.borderWidth = 1
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = imageView.frame.width/2
    
    StorageManager.shared.downloadURL(for: path, completion: { result in
      switch result {
      case .success(let url):
        imageView.getCachedImage(url.absoluteString)
        
      case .failure(let error):
        print("Failed to get download url: \(error)")
      }
    })
    return imageView
  }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    records.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else {
      return .init()
    }
    cell.setUp(with: records[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    records[indexPath.row].handler?()
  }
}

// MARK: - ProfileViewModelType

extension ProfileViewController {
  
  enum ProfileViewModelType {
    case info, logout
  }
  
  struct ProfileModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
    
    init(_ viewModelType: ProfileViewModelType, title: String, handler: (() -> Void)? = nil) {
      self.viewModelType = viewModelType
      self.title = title
      self.handler = handler
    }
  }
}

// MARK: - ProfileTableViewCell

extension ProfileViewController {
  
  class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileModel) {
      textLabel?.text = viewModel.title
      
      switch viewModel.viewModelType {
      case .info:
        textLabel?.textAlignment = .left
        selectionStyle = .none
        
      case .logout:
        textLabel?.textColor = .red
        textLabel?.textAlignment = .center
      }
    }
  }
}

// MARK: - Log Out

extension ProfileViewController {
  
  private func signOut() {
    let actionSheet = UIAlertController(
      title: "Warning",
      message: "User data will be cleared completely from this device",
      preferredStyle: .actionSheet)
    
    let logoutButton = UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
      do {
        try FirebaseAuth.Auth.auth().signOut()
        
        UserDefaults.standard.setValue(nil, forKey: "email")
        UserDefaults.standard.setValue(nil, forKey: "name")
        
        let navigation = UINavigationController(rootViewController: LoginViewController())
        navigation.modalPresentationStyle = .fullScreen
        navigation.navigationBar.prefersLargeTitles = true
        self?.present(navigation, animated: true)
        
      } catch {
        self?.showAlert("Error", message: "Failed to signOut, please try again")
      }
    }
    actionSheet.addAction(logoutButton)
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    if let popOver = actionSheet.popoverPresentationController {
      self.modalPresentationStyle = .popover
      popOver.sourceView = view
      popOver.sourceRect = CGRect(x: view.bounds.midX,
                                  y: view.bounds.midY,
                                  width: 0, height: 0)
    }
    present(actionSheet, animated: true)
  }
}

//
//  RegisterViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
  
  private lazy var scrollView: UIScrollView = {
    $0.clipsToBounds = true
    $0.isScrollEnabled = true
    $0.isUserInteractionEnabled = true
    return $0
  }(UIScrollView())
  
  private lazy var imageView: UIImageView = {
    $0.image = .init(systemName: "person.circle")
    $0.tintColor = .darkGray.withAlphaComponent(0.5)
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.separator.cgColor
    $0.layer.cornerRadius = 30
    $0.isUserInteractionEnabled = true
    return $0
  }(UIImageView())
  
  private lazy var firstNameField: UITextField = {
    $0.autocapitalizationType = .none
    $0.autocorrectionType = .no
    $0.returnKeyType = .next
    $0.layer.cornerRadius = 16
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.placeholder = "First Name"
    $0.leftView = .init(frame: .init(x: 0, y: 0, width: 10, height: 0))
    $0.leftViewMode = .always
    $0.delegate = self
    $0.clearButtonMode = .whileEditing
    $0.backgroundColor = .secondarySystemGroupedBackground
    return $0
  }(UITextField())
  
  private lazy var lastNameField: UITextField = {
    $0.autocapitalizationType = .none
    $0.autocorrectionType = .no
    $0.returnKeyType = .next
    $0.layer.cornerRadius = 16
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.placeholder = "Last Name"
    $0.leftView = .init(frame: .init(x: 0, y: 0, width: 10, height: 0))
    $0.leftViewMode = .always
    $0.delegate = self
    $0.clearButtonMode = .whileEditing
    $0.backgroundColor = .secondarySystemGroupedBackground
    return $0
  }(UITextField())
  
  private lazy var emailField: UITextField = {
    $0.autocapitalizationType = .none
    $0.autocorrectionType = .no
    $0.returnKeyType = .next
    $0.keyboardType = .emailAddress
    $0.layer.cornerRadius = 16
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.placeholder = "Email Address"
    $0.leftView = .init(frame: .init(x: 0, y: 0, width: 10, height: 0))
    $0.leftViewMode = .always
    $0.delegate = self
    $0.clearButtonMode = .whileEditing
    $0.backgroundColor = .secondarySystemGroupedBackground
    return $0
  }(UITextField())
  
  private lazy var passwordField: UITextField = {
    $0.autocapitalizationType = .none
    $0.autocorrectionType = .no
    $0.returnKeyType = .done
    $0.isSecureTextEntry = true
    $0.layer.cornerRadius = 16
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.placeholder = "Password"
    $0.leftView = .init(frame: .init(x: 0, y: 0, width: 10, height: 0))
    $0.leftViewMode = .always
    $0.delegate = self
    $0.clearButtonMode = .whileEditing
    $0.backgroundColor = .secondarySystemGroupedBackground
    return $0
  }(UITextField())
  
  private lazy var registerButton: UIButton = {
    $0.setTitle("Register", for: .normal)
    $0.setTitleColor(.label, for: .normal)
    $0.backgroundColor = .systemGreen.withAlphaComponent(0.8)
    $0.layer.cornerRadius = 16
    $0.layer.masksToBounds = true
    $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    return $0
  }(UIButton())
  
  private var imagePicker: ImagePickerVC?
  
  // MARK: -
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    title = "Register"
    view.backgroundColor = .systemBackground
    setupSubViews()
  }
  
  private func setupSubViews() {
    view.addSubview(scrollView)
    scrollView.addSubViews(
      imageView, firstNameField, lastNameField,
      emailField, passwordField, registerButton)
    
    registerButton.addTarget(self, action: #selector(registerButtonClicked), for: .touchUpInside)
    let gesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
    gesture.numberOfTapsRequired = 1
    imageView.addGestureRecognizer(gesture)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    let viewHeight: CGFloat = 44
    let padding: CGFloat = 20
    scrollView.frame = view.bounds
    
    NSLayoutConstraint.activate([
    
      imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: padding),
      imageView.widthAnchor.constraint(equalToConstant: view.frame.size.width/3),
      imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
      imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
      
      firstNameField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
      firstNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      firstNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      firstNameField.heightAnchor.constraint(equalToConstant: viewHeight),
      
      lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: padding),
      lastNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      lastNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      lastNameField.heightAnchor.constraint(equalToConstant: viewHeight),
      
      emailField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: padding),
      emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      emailField.heightAnchor.constraint(equalToConstant: viewHeight),
      
      passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: padding),
      passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      passwordField.heightAnchor.constraint(equalToConstant: viewHeight),
      
      registerButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: padding),
      registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      registerButton.heightAnchor.constraint(equalToConstant: viewHeight),
    ])
  }
}

// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == firstNameField {
      lastNameField.becomeFirstResponder()
    } else if textField == lastNameField {
      emailField.becomeFirstResponder()
    } else if textField == emailField {
      passwordField.becomeFirstResponder()
    } else if textField == passwordField {
      registerButtonClicked()
    }
    return true
  }
}

// MARK: - Profile Image

extension RegisterViewController: ImagePickerViewDelegate {
  
  @objc private func changeProfilePicture() {
    let imagePicker = ImagePickerVC()
    imagePicker.delegate = self
    imagePicker.presentImagePicker(self)
    self.imagePicker = imagePicker
  }
  
  func selectedImage(_ image: UIImage) {
    imageView.image = image
  }
}

// MARK: - Save

extension RegisterViewController {
  
  @objc private func registerButtonClicked() {
    resignFirstResponderForView(firstNameField, lastNameField, emailField, passwordField)
    
    guard let firstName = firstNameField.text, firstName.isNotEmpty else {
      showAlert("Warning", message: "Please Enter your first name")
      return
    }
    
    guard let lastName = lastNameField.text, lastName.isNotEmpty else {
      showAlert("Warning", message: "Please Enter your last name")
      return
    }
    
    guard let email = emailField.text, email.isValidEmail else {
      showAlert("Warning", message: "Please Enter your valid email address")
      return
    }
    
    guard let password = passwordField.text, password.count >= 6 else {
      showAlert("Warning", message: "Please Enter valid password, Minimum six character")
      return
    }
    let user = User(
      firstName: firstName,
      lastName: lastName,
      emailAddress: email,
      password: password,
      profileImage: imageView.image?.pngData())
    registerButton.setTitle("Creating...", for: .normal)
    
    DatabaseManager.shared.checkAndCreateUser(for: user) { [weak self] error in
      guard let self else { return }
      guard error == nil else {
        registerButton.setTitle("Register", for: .normal)
        self.showAlert("Unable to create user", message: error?.localizedLowercase)
        return
      }
      
      let navigationVC = UINavigationController(rootViewController: HomeViewController())
      navigationVC.modalPresentationStyle = .fullScreen
      navigationVC.navigationBar.prefersLargeTitles = true
      present(navigationVC, animated: true)
    }
  }
}

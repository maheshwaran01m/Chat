//
//  LoginViewController.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
  
  private lazy var scrollView: UIScrollView = {
    $0.clipsToBounds = true
    $0.isScrollEnabled = true
    $0.isUserInteractionEnabled = true
    return $0
  }(UIScrollView())
  
  private lazy var imageView: UIImageView = {
    $0.image = .init(named: "logo")
    return $0
  }(UIImageView())
  
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
  
  private lazy var loginButton: UIButton = {
    $0.setTitle("Sign In", for: .normal)
    $0.setTitleColor(.label, for: .normal)
    $0.backgroundColor = .systemBlue.withAlphaComponent(0.8)
    $0.layer.cornerRadius = 16
    $0.layer.masksToBounds = true
    $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    return $0
  }(UIButton())
  
  private lazy var signUpButton: UIButton = {
    $0.setTitle("Sign Up", for: .normal)
    $0.setTitleColor(.label, for: .normal)
    $0.backgroundColor = .systemGreen.withAlphaComponent(0.8)
    $0.layer.cornerRadius = 16
    $0.layer.masksToBounds = true
    $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    return $0
  }(UIButton())
  
  // MARK: - Override Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    title = "Login"
    view.backgroundColor = .systemBackground
    setupSubViews()
  }
  
  private func setupSubViews() {
    view.addSubview(scrollView)
    scrollView.addSubViews(imageView, emailField, passwordField, loginButton, signUpButton)
    setupConstraints()
    addButtonActions()
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
      
      emailField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
      emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      emailField.heightAnchor.constraint(equalToConstant: viewHeight),
      
      passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: padding),
      passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      passwordField.heightAnchor.constraint(equalToConstant: viewHeight),
      
      loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: padding),
      loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      loginButton.heightAnchor.constraint(equalToConstant: viewHeight),
      
      signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: padding),
      signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      signUpButton.heightAnchor.constraint(equalToConstant: viewHeight),
    ])
  }
  
  private func addButtonActions() {
    signUpButton.addTarget(self, action: #selector(signUpButtonClicked), for: .touchUpInside)
    loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
  }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailField {
      passwordField.becomeFirstResponder()
    } else if textField == passwordField {
      loginButtonClicked()
    }
    return true
  }
}

// MARK: - Login

extension LoginViewController {
  
  @objc private func signUpButtonClicked() {
    let vc = RegisterViewController()
    vc.title = "Sign Up"
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc private func loginButtonClicked() {
    resignFirstResponderForView(emailField, passwordField)
    
    guard let email = emailField.text, email.isValidEmail else {
      showAlert("Warning", message: "Please Enter your valid email address")
      return
    }
    
    guard let password = passwordField.text, password.count >= 6 else {
      showAlert("Warning", message: "Please Enter valid password")
      return
    }
    loginButton.setTitle("Signing In...", for: .normal)
    DatabaseManager.shared.signIn(for: email, password: password) {[weak self] error in
      guard let self else { return }
      guard error == nil else {
        loginButton.setTitle("Sign Up", for: .normal)
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

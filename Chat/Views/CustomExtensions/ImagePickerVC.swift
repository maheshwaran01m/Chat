//
//  ImagePickerVC.swift
//  Chat
//
//  Created by MAHESHWARAN on 07/01/24.
//

import UIKit

protocol ImagePickerViewDelegate: AnyObject {
  func selectedImage(_ image: UIImage)
}

class ImagePickerVC: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  weak var delegate: ImagePickerViewDelegate?
  
  func presentImagePicker(_ vc: UIViewController) {
    
    let actionSheet = UIAlertController(
      title: "Profile Picture",
      message: "How would you like to select a Picture",
      preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(
      title: "Cancel",
      style: .cancel,
      handler: nil))
    
    actionSheet.addAction(UIAlertAction(
      title: "Take Photo",
      style: .default,
      handler: { [weak self]  _ in
        self?.presentCamera(vc)
      }))
    
    actionSheet.addAction(UIAlertAction(
      title: "Choose Photo",
      style: .default,
      handler: { [weak self] _ in
        self?.presentPhotPicker(vc)
      }))
    vc.present(actionSheet, animated: true)
  }
  
  private func presentCamera(_ parent: UIViewController) {
    let vc = UIImagePickerController()
    vc.sourceType = .camera
    vc.delegate = self
    vc.allowsEditing = true
    parent.present(vc, animated: true)
  }
  
  private func presentPhotPicker(_ parent: UIViewController) {
    let vc = UIImagePickerController()
    vc.sourceType = .photoLibrary
    vc.delegate = self
    vc.allowsEditing = true
    parent.present(vc, animated: true)
  }
  
  public func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
      return
    }
    delegate?.selectedImage(image)
  }
  
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}

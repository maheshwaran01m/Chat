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
  
  func presentImagePicker(_ vc: UIViewController, title: String = "Profile Picture") {
    
    let actionSheet = UIAlertController(
      title: title,
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
    if let popOver = actionSheet.popoverPresentationController {
      vc.modalPresentationStyle = .popover
      popOver.sourceView = vc.view
      popOver.sourceRect = CGRect(x: vc.view.bounds.midX,
                                  y: vc.view.bounds.midY,
                                  width: 0, height: 0)
    }
    
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

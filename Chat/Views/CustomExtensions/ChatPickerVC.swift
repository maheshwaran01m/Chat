//
//  ChatPickerVC.swift
//  Chat
//
//  Created by MAHESHWARAN on 11/01/24.
//

import UIKit
import CoreLocation

protocol ChatPickerDelegate: AnyObject {
  func selectedImage(_ image: UIImage)
  func selectedVideoURL(_ url: URL)
  func selectedLocationCoordinates(_ latitude: Double, longitude: Double)
}

class ChatPickerVC: NSObject {
  
  weak var delegate: ChatPickerDelegate?
  
  private var imagePicker: ImagePickerVC?
  
  func presentPickerVC(_ vc: UIViewController, for button: UIButton? = nil) {
    
    let actionSheet = UIAlertController(title: "Attach Media", message: "What Would you like to Attach", preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
      self?.presentPhotoPicker(for: vc)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self]  _ in
      self?.presentVideoPicker(for: vc)
    }))
   
    actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self]  _ in
      self?.presentLocationPicker(for: vc)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
    
    if let popOver = actionSheet.popoverPresentationController {
      vc.modalPresentationStyle = .popover
      popOver.sourceView = vc.view
      if let button {
        popOver.sourceRect = button.frame
      } else {
        popOver.sourceRect = CGRect(
          x: vc.view.bounds.midX,
          y: vc.view.bounds.midY,
          width: 0, height: 0)
      }
    }
    
    vc.present(actionSheet, animated: true)
  }
}

// MARK: - Photo

extension ChatPickerVC: ImagePickerViewDelegate {
  
  private func presentPhotoPicker(for vc: UIViewController) {
    let imagePicker = ImagePickerVC()
    imagePicker.delegate = self
    imagePicker.presentImagePicker(vc, title: "Attach Photo")
    self.imagePicker = imagePicker
  }
  
  func selectedImage(_ image: UIImage) {
    delegate?.selectedImage(image)
  }
}

// MARK: - Video

extension ChatPickerVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  private func presentVideoPicker(for vc: UIViewController) {
    
    let actionSheet = UIAlertController(title: "Attach Video", message: "Where Would you like to Attach Video", preferredStyle: .actionSheet)
    
    actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .camera
      picker.delegate = self
      picker.mediaTypes = ["public.movie"]
      picker.videoQuality = .typeMedium
      
      picker.allowsEditing = true
      vc.present(picker, animated: true)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: {[weak self]  _ in
      let picker = UIImagePickerController()
      picker.sourceType = .photoLibrary
      picker.delegate = self
      picker.mediaTypes = ["public.movie"]
      picker.videoQuality = .typeMedium
      picker.allowsEditing = true
      vc.present(picker, animated: true)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    if let popOver = actionSheet.popoverPresentationController {
      vc.modalPresentationStyle = .popover
      popOver.sourceView = vc.view
      popOver.sourceRect = CGRect(x: vc.view.bounds.midX,
                                  y: vc.view.bounds.midY,
                                  width: 0, height: 0)
    }
    
    vc.present(actionSheet, animated: true)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let videoUrl = info[.mediaURL] as? URL else { return }
    delegate?.selectedVideoURL(videoUrl)
  }
}

// MARK: - Location

extension ChatPickerVC {
  
  private func presentLocationPicker(for vc: UIViewController) {
    let locationVC = LocationPickerVC { [weak self] coordinates in
      self?.delegate?.selectedLocationCoordinates(coordinates.latitude, longitude: coordinates.longitude)
    }
    vc.navigationController?.pushViewController(locationVC, animated: true)
  }
}

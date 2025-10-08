//
//  PhotoPickerView.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/02/2024.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import SwiftUI
import UIKit

/// This view should be used in conjuction with `PhotoPicker` view modifier.
public struct PhotoPickerView: UIViewControllerRepresentable {
  let sourceType: UIImagePickerController.SourceType
  let onComplete: (UIImage) -> Void
  
  public init(
    sourceType: UIImagePickerController.SourceType,
    onComplete: @escaping (UIImage) -> Void
  ) {
    self.sourceType = sourceType
    self.onComplete = onComplete
  }
  
  public func makeUIViewController(context: Context) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = sourceType
    imagePicker.delegate = context.coordinator
    return imagePicker
  }
  
  public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { /* --- */ }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(onComplete: onComplete)
  }
}

// MARK: - Coordinator
public extension PhotoPickerView {
  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let onComplete: (UIImage) -> Void
    
    public init(onComplete: @escaping (UIImage) -> Void) {
      self.onComplete = onComplete
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      guard let image = info[.originalImage] as? UIImage else {
        picker.dismiss(animated: true)
        return
      }
      picker.dismiss(animated: true) {
        self.onComplete(image)
      }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true)
    }
  }
}

#endif

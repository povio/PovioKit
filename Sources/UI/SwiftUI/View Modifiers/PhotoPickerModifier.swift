//
//  PhotoPickerModifier.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/02/2024.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import SwiftUI

public struct PhotoPickerModifier: ViewModifier {
  public typealias VoidHandler = () -> Swift.Void
  public typealias ImageHandler = (UIImage) -> Swift.Void
  
  @Binding var present: Bool
  var configuration: Configuration = .init()
  var removeHandler: VoidHandler?
  let imageHandler: ImageHandler
  
  @State private var showImageCapture: Bool = false
  @State private var showPhotoLibrary: Bool = false
  
  public func body(content: Content) -> some View {
    content
      .confirmationDialog("", isPresented: $present) {
        Button(configuration.takePhoto) {
          showImageCapture.toggle()
        }
        Button(configuration.chooseFromLibrary) {
          showPhotoLibrary.toggle()
        }
        if let removePhoto = configuration.removePhoto, removeHandler != nil {
          Button(removePhoto, role: .destructive) {
            removeHandler?()
          }
        }
      }
      .sheet(isPresented: $showPhotoLibrary) {
        PhotoPickerView(sourceType: .photoLibrary) { image in
          imageHandler(image)
        }
        .ignoresSafeArea()
      }
      .fullScreenCover(isPresented: $showImageCapture) {
        PhotoPickerView(sourceType: .camera) { image in
          imageHandler(image)
        }
        .ignoresSafeArea()
      }
  }
  
  public struct Configuration {
    let takePhoto: String
    let chooseFromLibrary: String
    let removePhoto: String?
    
    public init(
      takePhoto: String = "Take a Photo",
      chooseFromLibrary: String = "Choose from Library",
      removePhoto: String? = "Remove Photo"
    ) {
      self.takePhoto = takePhoto
      self.chooseFromLibrary = chooseFromLibrary
      self.removePhoto = removePhoto
    }
  }
}

public extension View {
  func photoPicker(
    present: Binding<Bool>,
    configuration: PhotoPickerModifier.Configuration = .init(),
    removeHandler: PhotoPickerModifier.VoidHandler?,
    imageHandler: @escaping PhotoPickerModifier.ImageHandler
  ) -> some View {
    modifier(PhotoPickerModifier(
      present: present,
      configuration: configuration,
      removeHandler: removeHandler,
      imageHandler: imageHandler
    ))
  }
}

#endif

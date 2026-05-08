//
//  PhotoPickerComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 06/01/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI
import PovioKitSwiftUI

struct PhotoPickerComponent: View {
  @State private var selectedPhoto: Image?
  @State private var showPhotoPicker: Bool = false
  
  var body: some View {
    VStack(spacing: 50) {
      selectedPhoto?
        .resizable()
        .squared(cornerRadius: 38)
        .frame(size: 200)
      Button("Pick a photo") {
        showPhotoPicker.toggle()
      }
      .buttonStyle(.bordered)
    }
    .photoPicker(present: $showPhotoPicker, configuration: .init(
      removePhoto: selectedPhoto != nil ? "Remove" : nil
    )) {
      selectedPhoto = nil
    } imageHandler: { image in
      selectedPhoto = Image(uiImage: image)
    }
  }
}

#Preview {
  PhotoPickerComponent()
}

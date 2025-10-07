//
//  RemoteImageComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 25/02/2025.
//

import PovioKitCore
import PovioKitSwiftUI
import SwiftUI

struct RemoteImageComponent: View {
  var body: some View {
    RemoteImage(
      url: URL(string: "https://shorturl.at/YBTnX"),
      animated: true
    )
    .placeholder {
      Text("Loading...")
    }
    .onSuccess { _ in
      Logger.debug("On success")
    }
    .onFailure{ error in
      Logger.debug("On error \(error)!")
    }
    .squared()
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .overlay {
      RoundedRectangle(cornerRadius: 10)
        .stroke(.gray, lineWidth: 1)
    }
    .padding(20)
  }
}

#Preview {
  RemoteImageComponent()
}

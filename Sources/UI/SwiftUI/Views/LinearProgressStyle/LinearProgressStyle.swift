//
//  LinearProgressStyle.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/03/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

public struct LinearProgressStyle: ProgressViewStyle {
  var trackColor: Color = .gray
  var progressColor: Color = .black
  var cornerRadius: CGFloat = 8
  
  public init(
    trackColor: Color = .gray,
    progressColor: Color = .black,
    cornerRadius: CGFloat = 8
  ) {
    self.trackColor = trackColor
    self.progressColor = progressColor
    self.cornerRadius = cornerRadius
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    let completed = configuration.fractionCompleted ?? 0
    return GeometryReader { geo in
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(trackColor)
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(progressColor)
          .frame(width: completed * geo.size.width)
      }
    }
  }
}

#Preview {
  VStack {
    ProgressView(value: 0.5)
      .progressViewStyle(LinearProgressStyle())
      .frame(height: 5)
    
    ProgressView(value: 0.8)
      .progressViewStyle(LinearProgressStyle(
        progressColor: .red,
        cornerRadius: 10
      ))
      .frame(height: 20)
  }
  .padding(.horizontal, 20)
}

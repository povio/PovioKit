//
//  ContentView.swift
//  Storybook
//
//  Created by Borut Tomazin on 23/01/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @State private var path = NavigationPath()
  
  var body: some View {
    NavigationStack(path: $path) {
      VStack {
        Image("PovioKit")
          .resizable()
          .scaledToFit()
          .padding(50)
        
        Text("Storybook")
          .font(.system(size: 30))
          .foregroundColor(.blue)
          .padding(-50)
        
        NavigationLink("Components list", value: "Components")
          .padding(.top)
          .foregroundColor(.black)
          .buttonStyle(.bordered)
          .navigationDestination(for: String.self) { string in
            List {
              ForEach(Component.allCases, id: \.self) { component in
                NavigationLink(value: component) {
                  Text(component.name)
                }
              }
            }
            .navigationTitle("Components")
            .navigationDestination(for: Component.self) { component in
              switch component {
              case .photoPicker:
                PhotoPickerComponent()
                  .navigationTitle(component.name)
              case .animatedImage:
                AnimatedImageComponent()
                  .navigationTitle(component.name)
              case .remoteImage:
                RemoteImageComponent()
                  .navigationTitle(component.name)
              case .materialBlur:
                MaterialBlurComponent()
                  .navigationTitle(component.name)
              case .linearProgressStyle:
                LinearProgressStyleComponent()
                  .navigationTitle(component.name)
              case .scrollViewWithOffset:
                ScrollViewWithOffsetComponent()
                  .navigationBarTitleDisplayMode(.inline)
              case .deviceShake:
                DeviceShakeComponent()
                  .navigationTitle(component.name)
              case .swiftUIExtras:
                SwiftUIExtrasComponent()
                  .navigationTitle(component.name)
              case .money:
                MoneyComponent()
                  .navigationTitle(component.name)
              case .retry:
                RetryComponent()
                  .navigationTitle(component.name)
              case .asyncDebounce:
                AsyncDebounceComponent()
                  .navigationTitle(component.name)
              }
            }
            .navigationBarTitleDisplayMode(.large)
          }
      }
      .navigationTitle("Home")
      .toolbar(.hidden)
      .offset(x: 0, y: -100)
    }
  }
}

#Preview {
  ContentView()
}

//
//  ContentView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 2/27/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct SwitcherView: View {

  @Environment(AppModel.self) private var appModel

  var body: some View {
    VStack {
      Text("Switcher").font(.title)
      Button("Storyboard") {
        appModel.featureMode = .storyboard
      }
      Button("Hand Tracking") {
        appModel.featureMode = .handTracking
      }
      Button("Blocking") {
        appModel.featureMode = .blocking
      }
    }
    .padding()
  }
}

#Preview(windowStyle: .automatic) {
  SwitcherView()
    .environment(AppModel())
}

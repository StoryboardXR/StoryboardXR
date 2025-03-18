//
//  StoryboardView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/4/25.
//

import SwiftUI

struct StoryboardView: View {
  // MARK: Environment.
  @Environment(AppModel.self) private var appModel
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

  var body: some View {
    VStack {
      Text("Storyboard View").font(.title)
      Button("Switcher") {
        appModel.featureMode = .switcher
      }
    }
    .padding()
    // MARK: Immersive space handler.
    .onAppear {
      Task {
        await openImmersiveSpace(id: STORYBOARD_SPACE_ID)
      }
    }.onDisappear {
      Task {
        await dismissImmersiveSpace()
      }
    }
  }
}

//
//  StoryboardView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/4/25.
//

import SwiftUI
import ARKit

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
        // Begin immersive space for shots.
        await openImmersiveSpace(id: STORYBOARD_SPACE_ID)
        
        // Begin world tracking.
        try await appModel.arkitSesion.run([appModel.worldInfo])
        
        // Add default world anchor.
        if appModel.sceneWorldAnchor == nil {
          appModel.sceneWorldAnchor = WorldAnchor(originFromAnchorTransform: simd_float4x4())
          try await appModel.worldInfo.addAnchor(appModel.sceneWorldAnchor!)
        }
        
        // Show updates on tracking.
        for await update in appModel.worldInfo.anchorUpdates {
          switch update.event {
          case .added, .updated:
            print("Anchor position updated.")
          case .removed:
            print("Anchor position now unknown")
          }
        }
      }
    }.onDisappear {
      Task {
        await dismissImmersiveSpace()
      }
    }
  }
}

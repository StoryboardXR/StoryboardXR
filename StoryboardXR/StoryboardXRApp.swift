//
//  StoryboardXRApp.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 2/27/25.
//

import SwiftUI

@main
struct StoryboardXRApp: App {

  // MARK: States.
  @State private var appModel = AppModel()

  var body: some Scene {
    WindowGroup {
      switch appModel.featureMode {
      case .switcher:
        SwitcherView().environment(appModel)
      case .storyboard:
        StoryboardView().environment(appModel)
      case .handTracking:
        HandTrackingView().environment(appModel)
      case .blocking:
        BlockingView().environment(appModel)
      }
    }

    ImmersiveSpace(id: STORYBOARD_SPACE_ID) {
      OriginRealityView().environment(appModel)
      
      // FIXME: Race condition. Need origin to be loaded first.
      ForEach(appModel.shots) { shotModel in
        ShotRealityView(shotModel: shotModel).environment(appModel)
      }
    }
    .immersionStyle(selection: .constant(.mixed), in: .mixed)
  }
}

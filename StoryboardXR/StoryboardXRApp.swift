//
//  StoryboardXRApp.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 2/27/25.
//

import SwiftUI

@main
struct StoryboardXRApp: App {

  // MARK: States
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
      HandTrackingRealityView().environment(appModel)
      if appModel.originEntity != nil {
        ForEach(appModel.shots) { shotModel in
          ShotRealityView(shotModel: shotModel).environment(appModel)
        }
        ForEach(appModel.blockers) { blockerModel in
          BlockingRealityView(blockerModel: blockerModel).environment(appModel)
        }
      }
    }
    .immersionStyle(selection: .constant(.mixed), in: .mixed)

    ImmersiveSpace(id: "HandTrackingRealityView"){
        HandTrackingRealityView()
    }
  }
}

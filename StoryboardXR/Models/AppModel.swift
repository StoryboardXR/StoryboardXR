//
//  AppModel.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 2/27/25.
//

import SwiftUI
import ARKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
  // MARK: Feature modes.
  enum FeatureMode {
    case switcher
    case storyboard
    case handTracking
    case blocking
  }
  var featureMode: FeatureMode = .storyboard
  
  // MARK: World Tracking.
  let arkitSesion = ARKitSession()
  let worldInfo = WorldTrackingProvider()
  var sceneWorldAnchor: WorldAnchor?

  // MARK: Scene state.
  var sceneNumber = 1
  var shots: [ShotModel] = [ShotModel()]
}

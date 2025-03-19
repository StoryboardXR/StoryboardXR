//
//  AppModel.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 2/27/25.
//

import ARKit
import RealityFoundation
import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
  // MARK: Feature modes
  enum FeatureMode {
    case switcher
    case storyboard
    case handTracking
    case blocking
  }
  
  var featureMode: FeatureMode = .switcher

  // MARK: Head tracking
  let arkitSession = ARKitSession()
  let worldTrackingProvider = WorldTrackingProvider()
  
  // MARK: World position tracking.
  var shotFrameEntities = Set<Entity>()

  // MARK: Scene state
  var sceneNumber = 1
  var shots: [ShotModel] = []
  var originEntity: Entity?
}

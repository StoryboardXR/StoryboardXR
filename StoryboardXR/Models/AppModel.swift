//
//  AppModel.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 2/27/25.
//

import SwiftUI

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
  // MARK: Scene state.
  var sceneNumber = 1
  var shots: [ShotModel] = [ShotModel()]
  var featureMode: FeatureMode = .switcher
    
    
}

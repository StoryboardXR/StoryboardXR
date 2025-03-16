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
  var featureMode: FeatureMode = .storyboard
  
  // MARK: Instance state.
  var sceneNumber = 1
  
  // MARK:
}

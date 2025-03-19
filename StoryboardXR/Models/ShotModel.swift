//
//  ShotModel.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

import Foundation
import Spatial
import simd
import RealityFoundation

@MainActor
@Observable
class ShotModel: @preconcurrency Identifiable {
  // MARK: State
  var id = UUID()

  var name: ShotName = .unnamed
  var needInitialization: Bool = true
  var orientationLock: Bool = false

  var transform: Transform = .identity

  var notes: String = ""

  // MARK: Private properties
  private let appModel: AppModel

  init(appModel: AppModel) {
    // Capture reference to app model.
    self.appModel = appModel

    // Initialize name.
    incrementShotName()
  }

  // MARK: Helper functions

  /// Get all available shot names including this one.
  var unusedShotNames: [ShotName] {
    // Generate list of shot names.
    let currentShotName = name
    let usedNames: Set = Set(
      appModel.shots.compactMap { shotModel in shotModel.name })
    return ShotName.allCases.filter { name in
      name == currentShotName || !usedNames.contains(name)
    }
  }

  /// Set shot name to the next lexigraphically available one.
  func incrementShotName() {
    name =
      unusedShotNames[
        (unusedShotNames.firstIndex(of: name)! + 1) % unusedShotNames.count]
  }

  /// Set shot name to the previous lexigraphically available one.
  func decrementShotName() {
    name =
      unusedShotNames[
        (unusedShotNames.firstIndex(of: name)! - 1)
          % unusedShotNames.count]
  }
}

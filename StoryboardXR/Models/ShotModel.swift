//
//  ShotModel.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

import Foundation
import RealityFoundation
import Spatial
import simd

//@MainActor
@Observable
class ShotModel: Identifiable, Codable {
  // MARK: State
  var id = UUID()

  var name: ShotName = .unnamed
  var needInitialization: Bool = true
  var orientationLock: Bool = false

  var transform: Transform = .identity

  var notes: String = ""

  // MARK: Private properties
  private var appModel: AppModel? = nil

  @MainActor
  init(appModel: AppModel) {
    // Capture reference to app model.
    self.appModel = appModel

    // Initialize name.
    incrementShotName()
  }

  // MARK: Helper functions

  /// Get all available shot names including this one.
  @MainActor
  var unusedShotNames: [ShotName] {
    guard let appModel = appModel else { return [] }
    
    // Generate list of shot names.
    let currentShotName = name
    let usedNames: Set = Set(
      appModel.shots.compactMap { shotModel in shotModel.name })
    return ShotName.allCases.filter { name in
      name == currentShotName || !usedNames.contains(name)
    }
  }

  /// Set shot name to the next lexigraphically available one.
  @MainActor
  func incrementShotName() {
    name =
      unusedShotNames[
        (unusedShotNames.firstIndex(of: name)! + 1) % unusedShotNames.count]
  }

  /// Set shot name to the previous lexigraphically available one.
  @MainActor
  func decrementShotName() {
    name =
      unusedShotNames[
        (unusedShotNames.firstIndex(of: name)! - 1)
          % unusedShotNames.count]
  }

  // MARK: Codable

  /// Values to be encoded.
  enum CodingKeys: String, CodingKey {
    case _name = "name"
    case _needInitialization = "needInitialization"
    case _orientationLock = "orientationLock"
    case _transform = "transform"
    case _notes = "notes"
  }
  
  /// Decoder. Required to add in appModel reference after
  required init(from decoder: any Decoder) throws {
    id = UUID()
    
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    name = try values.decode(ShotName.self, forKey: ._name)
    needInitialization = try values.decode(Bool.self, forKey: ._needInitialization)
    orientationLock = try values.decode(Bool.self, forKey: ._orientationLock)
    transform = try values.decode(Transform.self, forKey: ._transform)
    notes = try values.decode(String.self, forKey: ._notes)
  }
  
  /// Encode model.
  func encoder(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: ._name)
    try container.encode(needInitialization, forKey: ._needInitialization)
    try container.encode(orientationLock, forKey: ._orientationLock)
    try container.encode(transform, forKey: ._transform)
    try container.encode(notes, forKey: ._notes)
  }
  
}

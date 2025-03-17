//
//  ShotModel.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

import Foundation
import Spatial
import simd

@Observable
class ShotModel: Identifiable {
  var id = UUID()

  var name: ShotName = .a

  var orientationLock: Bool = false

  var position: SIMD3<Float> = .zero
  var rotation: Rotation3D = .identity
  var scale: SIMD3<Float> = .one

  var notes: String = ""
}

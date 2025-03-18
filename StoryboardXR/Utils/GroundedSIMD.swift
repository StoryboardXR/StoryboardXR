//
//  GroundedSIMD.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/18/25.
//

extension SIMD3 where Scalar == Float {
  /// Ensure y-axis is 0.
  var grounded: SIMD3<Float> {
    return .init(x: x, y: 0, z: z)
  }
}

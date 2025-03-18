//
//  OriginRealityView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/18/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct OriginRealityView: View {
  // MARK: Environment.
  @Environment(AppModel.self) private var appModel

  // MARK: Gesture start markers.
  @State private var initialPosition: SIMD3<Float>? = nil
  @State private var initialRotation: simd_quatf? = nil

  var body: some View {
    RealityView { content in
      // Load the entity.
      guard
        let originEntity = try? await Entity(
          named: ORIGIN_ENTITY_NAME, in: realityKitContentBundle)
      else {
        assertionFailure("Failed to load origin model")
        return
      }

      // Add to the scene.
      content.add(originEntity)
    }
    .gesture(positionGesture)
    .gesture(rotationGesture)
  }

  // MARK: Orientation gestures.
  var positionGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
      .onChanged({ gesture in
        // Drag gesture entity.
        let rootEntity = gesture.entity

        // Capture initial position.
        if self.initialPosition == nil {
          self.initialPosition = rootEntity.transform.translation
        }

        // Compute the drag.
        let drag = gesture.convert(
          gesture.translation3D, from: .global, to: .scene)

        // Apply the drag.
        rootEntity.position = (initialPosition ?? .zero) + drag.grounded
      })
      .onEnded({ _ in
        // Reset initial position.
        initialPosition = nil
      })
  }

  var rotationGesture: some Gesture {
    RotateGesture3D(constrainedToAxis: .y)
      .targetedToAnyEntity()
      .onChanged({ gesture in
        // Rotate gesture entity.
        let rootEntity = gesture.entity

        // Capture initial rotation.
        if self.initialRotation == nil {
          self.initialRotation = rootEntity.transform.rotation
        }

        // Compute the rotation.
        let rotation = Rotation3D(initialRotation ?? .init()).rotated(
          by: gesture.rotation)

        // Apply the rotation.
        rootEntity.transform.rotation = simd_quatf(rotation)
      })
      .onEnded({ _ in
        // Reset initial rotation.
        initialRotation = nil
      })
  }
}

#Preview {
  OriginRealityView()
}

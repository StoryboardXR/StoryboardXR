//
//  FrameView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/5/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct FrameView: View {
  @State var initialPosition: SIMD3<Float>? = nil
  @State var initialScale: SIMD3<Float>? = nil
  @State var initialRotation: simd_quatf? = nil

  var body: some View {
    RealityView { content in
      // Frame model name.
      let modelName: String = "Frame"

      // Load the model
      guard
        let frame = try? await Entity(
          named: modelName, in: realityKitContentBundle)
      else {
        assertionFailure("Failed to load model: \(modelName)")
        return
      }

      // Get the model bounds.
      let bounds = frame.visualBounds(relativeTo: nil)

      // Spawn 1.5m off the ground
      frame.position.y = 1

      // Spawn somewhere in the visual bounds.
      frame.position.z -= bounds.boundingRadius

      // Add frame to the view
      content.add(frame)
    }.gesture(translationGesture).gesture(rotationGesture)
  }

  var rotationGesture: some Gesture {
    RotateGesture3D().targetedToAnyEntity().onChanged({ gesture in
      // Get the entity.
      let rootEntity = gesture.entity

      // Mark the current rotation at the start of the gesture.
      if initialRotation == nil {
        initialRotation = rootEntity.transform.rotation
      }
      
      // Extract angle and axis.
      let axis = gesture.rotation.axis
      let angle = gesture.rotation.angle
      
      // Flip the X and Z rotations.
      let flippedRotation = Rotation3D(angle: angle, axis: RotationAxis3D(x: -axis.x, y: axis.y, z: -axis.z))

      // Apply to entity.
      rootEntity.transform.rotation = simd_quatf(
        Rotation3D(initialRotation ?? .init()).rotated(by: flippedRotation))
    }).onEnded({ _ in
      initialRotation = nil
    })
  }

  var translationGesture: some Gesture {
    DragGesture().targetedToAnyEntity().onChanged({ value in
      // Get the entity.
      let rootEntity = value.entity

      // Mark the current position at the start of the drag.
      if initialPosition == nil {
        initialPosition = rootEntity.position
      }

      // Get the drag movement from world space to scene space.
      let drag = value.convert(value.translation3D, from: .global, to: .scene)

      // Apply the translation.
      rootEntity.position = (initialPosition ?? .zero) + drag
    }).onEnded({ _ in
      // Reset the initial position value for the next darg.
      initialPosition = nil
    })
  }

  var scaleGesture: some Gesture {
    MagnifyGesture().targetedToAnyEntity().onChanged({ gesture in
      // Get the entity.
      let rootEntity = gesture.entity

      // Mark the current scale at the start of the scale.
      if initialScale == nil {
        initialScale = rootEntity.scale
      }

      let scaleRate: Float = 1.0

      // Apply the scaling.
      rootEntity.scale =
        (initialScale ?? .init(repeating: scaleRate))
        * Float(gesture.gestureValue.magnification)
    }).onEnded({ _ in
      // Reset the initial scale for the next scale.
      initialScale = nil
    })
  }
}

#Preview {
  FrameView()
}

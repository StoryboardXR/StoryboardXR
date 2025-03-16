//
//  ShotRealityView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/5/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ShotRealityView: View {
  // MARK: Environment.
  @Environment(AppModel.self) private var appModel

  // MARK: Gesture start markers.
  @State var initialPosition: SIMD3<Float>? = nil
  @State var initialUserPosition: SIMD3<Float>? = nil
  @State var initialScale: SIMD3<Float>? = nil
  @State var initialRotation: simd_quatf? = nil

  var body: some View {
    RealityView { content, attachments in
      // MARK: Load the shot frame model.

      // Load the entity.
      guard
        let shotEntity = try? await Entity(
          named: "Shot", in: realityKitContentBundle)
      else {
        assertionFailure("Failed to load frame model")
        return
      }

      // Get the model bounds.
      let bounds = shotEntity.visualBounds(relativeTo: nil)

      // Spawn 1.5m off the ground
      shotEntity.position.y = 1

      // Spawn somewhere in the visual bounds.
      shotEntity.position.z -= bounds.boundingRadius

      // Add entity to the view.
      content.add(shotEntity)

      // MARK: Add control panel.
      if let controlPanelAttachment = attachments.entity(
        for: SHOT_CONTROL_PANEL_ATTACHMENT_ID)
      {
        shotEntity.addChild(controlPanelAttachment)

        controlPanelAttachment.setPosition([1, 0, 0], relativeTo: shotEntity)
      }
    } attachments: {
      Attachment(id: SHOT_CONTROL_PANEL_ATTACHMENT_ID) {
        ShotControlPanelView(dataIndex: 0).environment(appModel)
      }
    }
    .gesture(
      translationGesture
        .simultaneously(with: rotationGesture)
        .simultaneously(with: scaleGesture)
    )
  }

  /// Shot angle.
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
      let flippedRotation = Rotation3D(
        angle: angle, axis: RotationAxis3D(x: -axis.x, y: axis.y, z: -axis.z))

      // Apply to entity.
      rootEntity.transform.rotation = simd_quatf(
        Rotation3D(initialRotation ?? .init()).rotated(by: flippedRotation))
    }).onEnded({ _ in
      initialRotation = nil
    })
  }

  /// Shot placement.
  var translationGesture: some Gesture {
    DragGesture().targetedToAnyEntity().onChanged({ gesture in
      // Get the entity.
      let rootEntity = gesture.entity

      // Compute the headset placement.
      let currentUserPosition: SIMD3<Float> = gesture.convert(
        Vector3D.zero, from: .local, to: .scene)

      // Mark the current position at the start of the drag.
      if initialPosition == nil {
        initialPosition = rootEntity.position
        initialUserPosition = currentUserPosition
      }

      // Compute user movement.
      let userMovement = (initialUserPosition ?? .zero) - currentUserPosition

      // Get the drag movement from world space to scene space.
      let drag = gesture.convert(
        gesture.translation3D, from: .global, to: .scene)

      // Apply the translation.
      rootEntity.position = (initialPosition ?? .zero) + drag - userMovement
    }).onEnded({ _ in
      // Reset the initial position value for the next darg.
      initialPosition = nil
      initialUserPosition = nil
    })
  }

  /// Shot frame scaling.
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

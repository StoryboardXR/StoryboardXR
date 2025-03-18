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
  var shotModel: ShotModel

  // MARK: Gesture start markers.
  @State var initialPosition: SIMD3<Float>? = nil
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

        controlPanelAttachment.setPosition([0.1, 0, 0], relativeTo: shotEntity)
      }
    } attachments: {
      Attachment(id: SHOT_CONTROL_PANEL_ATTACHMENT_ID) {
        ShotControlPanelView(shotModel: shotModel).environment(appModel)
      }
    }
    .gesture(
      positionGesture
        .simultaneously(with: rotationGesture)
        .simultaneously(with: scaleGesture)
    )
  }

  /// Shot placement.
  var positionGesture: some Gesture {
    DragGesture().targetedToAnyEntity().onChanged({ gesture in
      // Exit if locked.
      if shotModel.orientationLock {
        return
      }

      // Get the root entity.
      var rootEntity: Entity {
        if let parentRootEntity = gesture.entity.parent {
          if parentRootEntity.name == "Root" {
            return parentRootEntity
          }
        }

        return gesture.entity
      }

      // Mark the current position at the start of the drag.
      if initialPosition == nil {
        initialPosition = rootEntity.position
      }

      // Get the drag movement from world space to scene space.
      let drag = gesture.convert(
        gesture.translation3D, from: .global, to: .scene)

      // Record and apply the position change.
      let newPosition = (initialPosition ?? .zero) + drag
      shotModel.position = newPosition
      rootEntity.position = newPosition
    }).onEnded({ _ in
      // Reset the initial position value for the next darg.
      initialPosition = nil
    })
  }

  /// Shot angle.
  var rotationGesture: some Gesture {
    RotateGesture3D().targetedToAnyEntity().onChanged({ gesture in
      // Exit if locked.
      if shotModel.orientationLock {
        return
      }

      // Get the root entity.
      var rootEntity: Entity {
        if let parentRootEntity = gesture.entity.parent {
          if parentRootEntity.name == "Root" {
            return parentRootEntity
          }
        }

        return gesture.entity
      }

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
      let newRotation = Rotation3D(initialRotation ?? .init()).rotated(
        by: flippedRotation)
      shotModel.rotation = newRotation
      rootEntity.transform.rotation = simd_quatf(newRotation)
    }).onEnded({ _ in
      initialRotation = nil
    })
  }

  /// Shot frame scaling.
  var scaleGesture: some Gesture {
    MagnifyGesture().targetedToAnyEntity().onChanged({ gesture in
      // Exit if locked.
      if shotModel.orientationLock {
        return
      }

      // Get the entity.
      let rootEntity = gesture.entity

      // Mark the current scale at the start of the scale.
      if initialScale == nil {
        initialScale = rootEntity.scale
      }

      let scaleRate: Float = 1.0

      // Apply the scaling.
      let newScale =
        (initialScale ?? .init(repeating: scaleRate))
        * Float(gesture.gestureValue.magnification)
      shotModel.scale = newScale
      rootEntity.scale = newScale
    }).onEnded({ _ in
      // Reset the initial scale for the next scale.
      initialScale = nil
    })
  }
}

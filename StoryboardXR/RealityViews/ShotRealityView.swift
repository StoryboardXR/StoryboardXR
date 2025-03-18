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
  @State private var initialPosition: SIMD3<Float>? = nil
  @State private var initialScale: SIMD3<Float>? = nil
  @State private var initialRotation: simd_quatf? = nil

  // MARK: Properties.
  @State private var controlPanelAttachmentEntity: Entity?

  // MARK: View.
  var body: some View {
    RealityView { content, attachments in
      // Load the entity.
      guard
        let shotFrameEntity = try? await Entity(
          named: SHOT_FRAME_ENTITY_NAME, in: realityKitContentBundle)
      else {
        assertionFailure("Failed to load frame model")
        return
      }
      
      // Create a head anchor to place the shot frame.
      let headAnchor = AnchorEntity(.head)
      headAnchor.anchoring.trackingMode = .once
      content.add(headAnchor)
      
      // Place the shot frame in front of the user.
      shotFrameEntity.setPosition([0, 0, -0.6], relativeTo: headAnchor)
      headAnchor.addChild(shotFrameEntity)

      // Add control panel.
      if let controlPanelAttachmentEntity = attachments.entity(
        for: SHOT_CONTROL_PANEL_ATTACHMENT_ID)
      {
        // Save reference to panel.
        self.controlPanelAttachmentEntity = controlPanelAttachmentEntity

        // Add the control panel to the shot frame.
        shotFrameEntity.addChild(controlPanelAttachmentEntity)

        // Position control panel.
        positionControlPanel(shotFrameEntity: shotFrameEntity)
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

  // MARK: Orientation gestures.

  /// Shot placement.
  var positionGesture: some Gesture {
    DragGesture().targetedToAnyEntity().onChanged({ gesture in
      // Exit if locked.
      if shotModel.orientationLock {
        return
      }

      // Get the higher root entity (with the control panel).
      let rootEntity = gesture.entity.parent!

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

      // Get the higher root entity (with the control panel).
      let rootEntity = gesture.entity.parent!

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

      // Get the root entity but not the parent with the control panel.
      let rootEntity = gesture.entity.parent!

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

      // Update the control panel's position
//      positionControlPanel(shotFrameEntity: rootEntity.parent)
    }).onEnded({ _ in
      // Reset the initial scale for the next scale.
      initialScale = nil
    })
  }

  // MARK: Helper functions.

  /// Position the control panel attachment entity next to the frame.
  func positionControlPanel(shotFrameEntity: Entity) {
    // Exit if no control panel exist.
    if let unwrappedControlPanelAttachmentEntity = controlPanelAttachmentEntity
    {
      unwrappedControlPanelAttachmentEntity.setPosition(
        [
          shotFrameEntity.visualBounds(relativeTo: nil).boundingRadius
            + unwrappedControlPanelAttachmentEntity.visualBounds(
              relativeTo: nil
            )
            .boundingRadius, 0, 0,
        ], relativeTo: shotFrameEntity)
    }
  }
}

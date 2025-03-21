//
//  ShotRealityView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/5/25.
//

import ARKit
import RealityKit
import RealityKitContent
import SwiftUI

struct ShotRealityView: View {
  // MARK: Environment
  @Environment(AppModel.self) private var appModel
  var shotModel: ShotModel

  // MARK: Gesture start markers
  @State private var initialPosition: SIMD3<Float>? = nil
  @State private var initialScale: SIMD3<Float>? = nil
  @State private var initialRotation: simd_quatf? = nil

  // MARK: View
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

      // Initialize or pull existing transform.
      if shotModel.needInitialization {
        Task {
          do {
            // Ensure the tracking system is running.
            if appModel.worldTrackingProvider.state != .running {
              try await appModel.arkitSession.run([
                appModel.worldTrackingProvider
              ])

              // Wait until it is running.
              while appModel.worldTrackingProvider.state != .running {
                try await Task.sleep(for: .milliseconds(100))
              }
            }

            // Get the current device transform.
            guard
              let deviceAnchor = appModel.worldTrackingProvider
                .queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
            else { return }
            let deviceMatrix = deviceAnchor.originFromAnchorTransform
            let deviceTransform = Transform(matrix: deviceMatrix)

            // Get the forward and down vectors.
            let forwardVector = SIMD3<Float>(
              -deviceMatrix.columns.2.x, -deviceMatrix.columns.2.y,
              -deviceMatrix.columns.2.z)
            let downVector = SIMD3<Float>(
              -deviceMatrix.columns.1.x, -deviceMatrix.columns.1.y,
              -deviceMatrix.columns.1.z)

            // Get the position in front of the user's face.
            let offsetPosition =
              deviceTransform.translation + (forwardVector * 0.6)
              + (downVector * 0.2)

            // Create this transform.
            var modifiedTransform = deviceTransform
            modifiedTransform.translation = offsetPosition

            // Apply it to the shot frame.
            shotFrameEntity.setTransformMatrix(
              modifiedTransform.matrix, relativeTo: appModel.originEntity)

            // Update the shot model.
            shotModel.transform = modifiedTransform
          } catch {
            print("Error setting shot frame position: \(error)")
          }
        }

        // Mark has been initialized.
        shotModel.needInitialization = false
      } else {
        shotFrameEntity.transform = shotModel.transform
      }

      // Add the shot frame to the world.
      content.add(shotFrameEntity)

      // Save a reference to the shot frame.
      appModel.shotFrameEntities.insert(shotFrameEntity)

      // Add control panel.
      guard
        let controlPanelAttachmentEntity = attachments.entity(
          for: SHOT_CONTROL_PANEL_ATTACHMENT_ID)
      else { return }
      shotFrameEntity.addChild(controlPanelAttachmentEntity)

      // Position it to the right of the frame.
      controlPanelAttachmentEntity.setPosition(
        [
          shotFrameEntity.visualBounds(relativeTo: nil).boundingRadius
            + controlPanelAttachmentEntity.visualBounds(relativeTo: nil)
            .boundingRadius, 0, 0,
        ], relativeTo: shotFrameEntity)
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

  // MARK: Orientation gestures

  /// Shot placement.
  var positionGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
      .onChanged({ gesture in
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
        shotModel.transform.translation = newPosition
        rootEntity.position = newPosition
      }).onEnded({ _ in
        // Reset the initial position value for the next drag.
        initialPosition = nil

        // Mark unsaved changes.
        appModel.unsavedChanges = true
      })
  }

  /// Shot angle.
  var rotationGesture: some Gesture {
    RotateGesture3D()
      .targetedToAnyEntity()
      .onChanged({ gesture in
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
        let newRotation = simd_quatf(
          Rotation3D(initialRotation ?? .init()).rotated(
            by: flippedRotation))
        shotModel.transform.rotation = newRotation
        rootEntity.transform.rotation = newRotation
      }).onEnded({ _ in
        // Reset the initial rotation value for the next rotation.
        initialRotation = nil

        // Mark unsaved changes.
        appModel.unsavedChanges = true
      })
  }

  /// Shot frame scaling.
  var scaleGesture: some Gesture {
    MagnifyGesture()
      .targetedToAnyEntity()
      .onChanged({ gesture in
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
        shotModel.transform.scale = newScale
        rootEntity.scale = newScale

        // Update the control panel's position
        //      positionControlPanel(shotFrameEntity: rootEntity.parent)
      }).onEnded({ _ in
        // Reset the initial scale for the next scale.
        initialScale = nil

        // Mark unsaved changes.
        appModel.unsavedChanges = true
      })
  }
}

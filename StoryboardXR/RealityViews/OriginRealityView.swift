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
  // MARK: Environment
  @Environment(AppModel.self) private var appModel

  // MARK: Gesture start markers
  @State private var initialPosition: SIMD3<Float>? = nil
  @State private var initialRotation: simd_quatf? = nil
  @State private var shotFrameEntityParent: Entity? = nil

  var body: some View {
    RealityView { content in
      // Load the entity.
      guard
        let loadedOriginEntity = try? await Entity(
          named: ORIGIN_ENTITY_NAME, in: realityKitContentBundle)
      else {
        assertionFailure("Failed to load origin model")
        return
      }

      // Add to the scene.
      content.add(loadedOriginEntity)

      // Keep reference to it in app state.
      appModel.originEntity = loadedOriginEntity
    }
    .onAppear {
      appModel.shots.append(ShotModel(appModel: appModel))
    }
    .gesture(positionGesture)
    .gesture(rotationGesture)
  }

  // MARK: Orientation gestures
  var positionGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
      .onChanged({ gesture in
        // Drag gesture root entity.
        guard let rootEntity = gesture.entity.parent else { return }

        // Gesture setup.
        if self.initialPosition == nil {
          // Capture initial position.
          self.initialPosition = rootEntity.transform.translation

          // Parent shot frames.
          for shotFrameEntity in appModel.shotFrameEntities {
            // Record parent to return to later.
            if shotFrameEntityParent == nil {
              shotFrameEntityParent = shotFrameEntity.parent!
            }

            // Parent it.
            shotFrameEntity.setParent(
              appModel.originEntity, preservingWorldTransform: true)
          }
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

        // Unparent shot frames.
        for shotFrameEntity in appModel.shotFrameEntities {
          shotFrameEntity.setParent(
            shotFrameEntityParent, preservingWorldTransform: true)
        }
        
        // Reset shot frame parent (this is not necessary, but is done for consistency).
        shotFrameEntityParent = nil
      })
  }

  var rotationGesture: some Gesture {
    RotateGesture3D(constrainedToAxis: .y)
      .targetedToAnyEntity()
      .onChanged({ gesture in
        // Drag gesture root entity.
        guard let rootEntity = gesture.entity.parent else { return }

        // Gesture setup.
        if self.initialRotation == nil {
          // Capture initial rotation.
          self.initialRotation = rootEntity.transform.rotation
          
          // Parent shot frames.
          for shotFrameEntity in appModel.shotFrameEntities {
            // Record parent to return to later.
            if shotFrameEntityParent == nil {
              shotFrameEntityParent = shotFrameEntity.parent!
            }

            // Parent it.
            shotFrameEntity.setParent(
              appModel.originEntity, preservingWorldTransform: true)
          }
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
        
        // Unparent shot frames.
        for shotFrameEntity in appModel.shotFrameEntities {
          shotFrameEntity.setParent(
            shotFrameEntityParent, preservingWorldTransform: true)
        }
        
        // Reset shot frame parent (this is not necessary, but is done for consistency).
        shotFrameEntityParent = nil
      })
  }
}

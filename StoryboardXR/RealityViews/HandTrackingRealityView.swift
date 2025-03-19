//  HandTrackingRealityView.swift
//  StoryboardXR
//
//  Created by Dalton Brockett on 3/15/25.

import SwiftUI
import RealityKit
import ARKit
import RealityKitContent

extension Notification.Name {
    static let shouldRemoveFrame = Notification.Name("shouldRemoveFrame")
}

// Extend HandTrackingSystem to expose whether an L gesture is active.
extension HandTrackingSystem {
    static var isLGestureActive: Bool {
        return Self.LGestureDetected
    }
}

struct HandTrackingRealityView: View {
    // Store a reference to the RealityView content for later use.
    @State private var sceneContent: (any RealityViewContentProtocol)? = nil
    @Environment(AppModel.self) private var appModel
    
    // MARK: - Ghost Frame Properties
    @State private var ghostFrameEntity: Entity? = nil
    @State private var ghostFrameAnchor: AnchorEntity? = nil
    @State private var ghostChirality: HandAnchor.Chirality? = nil

    var body: some View {
        RealityView { content in
            // Save the content on first appearance.
            if sceneContent == nil {
                sceneContent = content
                print("Scene content set.")
            }
            
            // Create the hand entities.
            makeHandEntities(in: content)
            
            // Create a local copy of content to avoid capturing an inout parameter.
            let contentCopy = content
            
            // Subscribe to scene update events so the ghost frame follows the hand.
            content.subscribe(to: SceneEvents.Update.self) { _ in
                updateGhostFrame(in: contentCopy)
            }
        }
        // When placement is confirmed, spawn a new frame (or take other actions).
        .onReceive(NotificationCenter.default.publisher(for: .shouldPlaceFrame)) { notification in
            if let chirality = notification.object as? HandAnchor.Chirality,
               sceneContent != nil {
                // For demonstration, add a new shot.
                appModel.shots.append(ShotModel())
                print("shouldPlaceFrame received. Chirality: \(chirality)")
            }
        }
        // When placement is possible, create the ghost frame.
        .onReceive(NotificationCenter.default.publisher(for: .couldPlaceFrame)) { notification in
            print(".couldPlaceFrame notification received.")
            if let chirality = notification.object as? HandAnchor.Chirality,
               let content = sceneContent {
                print("Creating ghost frame for chirality: \(chirality)")
                // Save the chirality for which the ghost is shown.
                ghostChirality = chirality
                
                // Create the ghost frame only once.
                if ghostFrameEntity == nil {
                    if let modelEntity = try? ModelEntity.load(named: SHOT_FRAME_ENTITY_NAME, in: realityKitContentBundle) {
                        print("Model entity loaded successfully.")
                        // Adjust the material to be semi-transparent.
                        if var modelComponent = modelEntity.components[ModelComponent.self] {
                            if let index = modelComponent.materials.firstIndex(where: { $0 is SimpleMaterial }) {
                                let newMaterial = SimpleMaterial(color: UIColor.white.withAlphaComponent(0.1), isMetallic: true)
                                modelComponent.materials[index] = newMaterial
                                modelEntity.components.set(modelComponent)
                                print("Material adjusted for transparency.")
                            }
                        }
                        
                        ghostFrameEntity = modelEntity
                        ghostFrameAnchor = AnchorEntity()
                        ghostFrameAnchor?.addChild(modelEntity)
                        content.add(ghostFrameAnchor!)
                        print("Ghost frame added to the scene.")
                    } else {
                        print("Failed to load shot frame entity.")
                    }
                } else {
                    print("Ghost frame already exists.")
                }
            }
        }
        // Listen for a notification that tells us to remove the ghost frame.
        .onReceive(NotificationCenter.default.publisher(for: .shouldRemoveFrame)) { _ in
            print("shouldRemoveFrame notification received. Removing ghost frame.")
            removeGhostFrame()
        }
    }
    
    // MARK: - Hand Entity Setup
    @MainActor
    func makeHandEntities(in content: any RealityViewContentProtocol) {
        // Create and add the left hand entity.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)
        print("Left hand entity added.")
        
        // Create and add the right hand entity.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
        print("Right hand entity added.")
    }
    
    // MARK: - Ghost Frame Update
    /// Update the ghost frame's position and rotation so that its origin (bottom-left)
    /// aligns with the index finger metacarpal joint.
    @MainActor
    func updateGhostFrame(in content: any RealityViewContentProtocol) {
        // Check if the L gesture is still active.
        if !HandTrackingSystem.isLGestureActive {
            removeGhostFrame()
            return
        }
        // Ensure we have a valid chirality for the ghost frame.
        guard let chirality = ghostChirality else { return }
        
        // Get the current hand anchor based on chirality.
        let handAnchor: HandAnchor? = (chirality == .left) ? HandTrackingSystem.currentLeftHand : HandTrackingSystem.currentRightHand
        
        // If no hand anchor exists, do not update.
        guard let handAnchor = handAnchor, let ghostFrameAnchor = ghostFrameAnchor else { return }
        
        // Use the hand skeleton to position the ghost frame at the index finger metacarpal joint.
       
            // Fallback: use the overall hand anchor's transform.
            let handTransform = handAnchor.originFromAnchorTransform
            ghostFrameAnchor.transform.translation = SIMD3<Float>(
                handTransform.columns.3.x,
                handTransform.columns.3.y,
                handTransform.columns.3.z
            )
            ghostFrameAnchor.transform.rotation = simd_quatf(handTransform)
            print("Fallback: Updated ghost frame position to hand anchor.")
    }
    
    // MARK: - Optional: Remove Ghost Frame
    /// Removes the ghost frame from the scene.
    func removeGhostFrame() {
        ghostFrameEntity?.removeFromParent()
        ghostFrameEntity = nil
        ghostFrameAnchor = nil
        ghostChirality = nil
        print("Ghost frame removed.")
    }
}

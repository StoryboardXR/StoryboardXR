//
//  HandTrackingView.swift
//  StoryboardXR
//
//  Created by Dalton Brockett on 3/15/25.
//

import SwiftUI
import RealityKit
import ARKit

struct HandTrackingView: View {
    // Store a reference to the RealityView content for later use.
    @State private var sceneContent: (any RealityViewContentProtocol)? = nil
    @State private var appModel = AppModel()

    var body: some View {
        RealityView { content in
            // Save the content on first appearance.
            if sceneContent == nil {
                sceneContent = content
            }
            makeHandEntities(in: content)
        }
        .onReceive(NotificationCenter.default.publisher(for: .shouldPlaceFrame)) { notification in
            if let chirality = notification.object as? HandAnchor.Chirality,
               let content = sceneContent {
                // Now that we have the captured content, add the sphere.
                addTestSphere(in: content, for: chirality)
                
                //Woohooo sphere spawning works on special gesture, let's get some frames loaded in based off this
            }
        }
    }

    @MainActor
    func makeHandEntities(in content: any RealityViewContentProtocol) {
        // Create and add the left hand entity.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)
        
        // Create and add the right hand entity.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
    }
    
    @MainActor
    func addTestSphere(in content: any RealityViewContentProtocol, for chirality: HandAnchor.Chirality) {
        let sphereRadius: Float = 0.1
        let sphereMaterial = SimpleMaterial(color: .purple, isMetallic: false)
        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: sphereRadius), materials: [sphereMaterial])
        
        // Get the current hand anchor for the given chirality.
        let handAnchor: HandAnchor? = (chirality == .left) ? HandTrackingSystem.currentLeftHand : HandTrackingSystem.currentRightHand
        guard let handAnchor = handAnchor else {
            print("No hand anchor available for chirality: \(chirality)")
            return
        }
        
        // Get the hand's transform and extract its position.
        let handTransform = handAnchor.originFromAnchorTransform
        let handPosition = SIMD3<Float>(handTransform.columns.3.x,
                                        handTransform.columns.3.y,
                                        handTransform.columns.3.z)
        
        // Compute the forward vector from the hand's transform.
        let forward = forwardVector(from: handTransform)
        
        // Define how far in front of the hand you want the sphere (in meters).
        let offsetDistance: Float = 0.2
        let spherePosition = handPosition + (forward * offsetDistance)
        
        // Create a new anchor at the computed sphere position.
        let sphereTransform = Transform(translation: spherePosition)
        let anchorEntity = AnchorEntity(world: sphereTransform.matrix)
        anchorEntity.addChild(sphereEntity)
        content.add(anchorEntity)
        
        print("Added test sphere for chirality: \(chirality) at position: \(spherePosition)")
    }

    // Helper function to compute the forward vector from a transform matrix.
    // (I'll probably end up changing the methodology for formatting our frames relative to hand
    //  but this works for now)
    func forwardVector(from transform: simd_float4x4) -> SIMD3<Float> {
        // In a column-major 4x4 matrix, column 2 represents the z-axis.
        // Negating it gives the forward direction in many ARKit/RealityKit setups.
        return -SIMD3<Float>(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)
    }

}

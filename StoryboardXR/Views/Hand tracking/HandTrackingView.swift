//
//  HandTrackingView.swift
//  StoryboardXR
//
//  Created by Dalton Brockett on 3/15/25.
//

import SwiftUI
import RealityKit
import ARKit

/// A reality view that contains all hand-tracking entities.
struct HandTrackingView: View {
    // A local flag to track if a frame should be placed.
    @State private var shouldPlaceFrame: Bool = false

    var body: some View {
        RealityView { content in
            makeHandEntities(in: content)
        }
        // Listen for the notification that signals frame placement.
        .onReceive(NotificationCenter.default.publisher(for: .shouldPlaceFrame)) { notification in
            // Optionally, you can inspect notification.object for additional info (e.g., chirality).
            print("Received notification to place frame.")
            shouldPlaceFrame = true
        }
    }

    /// Creates the hand-tracking entities.
    @MainActor
    func makeHandEntities(in content: any RealityViewContentProtocol) {
        // Left-hand entity.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)

        // Right-hand entity.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
    }
    
    /// Adds a test sphere to the scene.
    @MainActor
    func addTestSphere(in content: any RealityViewContentProtocol) {
        let sphereRadius: Float = 0.01
        let sphereMaterial = SimpleMaterial(color: .purple, isMetallic: false)
        let sphereEntity = ModelEntity(
            mesh: .generateSphere(radius: sphereRadius),
            materials: [sphereMaterial]
        )
        
        // Create an anchor with a fixed offset.
        let anchorEntity = AnchorEntity(world: .init(SIMD3<Float>(0.0, 0.0, -0.5)))
        anchorEntity.addChild(sphereEntity)
        content.add(anchorEntity)
        
        print("Test sphere added to the scene.")
    }
}

struct HandTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        HandTrackingView()
    }
}

//
//  HandTrackingRealityView.swift
//  StoryboardXR
//
//  Created by Dalton Brockett on 3/15/25.
//

import SwiftUI
import RealityKit
import ARKit

struct HandTrackingRealityView: View {
    // Store a reference to the RealityView content for later use.
    @State private var sceneContent: (any RealityViewContentProtocol)? = nil
    @Environment(AppModel.self) private var appModel

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
                //Woohooo sphere spawning works on special gesture, let's get some frames loaded in based off this
                appModel.shots.append(ShotModel())
                print(appModel.shots)
                print("Should be spawning in another frame...")
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
    
}

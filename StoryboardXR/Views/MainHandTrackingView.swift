//
//  HandTrackingView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/4/25.
//

import SwiftUI
import RealityKit
import ARKit

/// A reality view that contains all hand-tracking entities.
struct MainHandTrackingView: View {
    /// The main body of the view.
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    var body: some View {
        VStack {
            Text("Hand Tracking View!").font(.title)
            Button("Switcher") {
                appModel.featureMode = .switcher
            }
        }.padding().onAppear {
            Task {
              await openImmersiveSpace(id: "HandTrackingView")
            }
            
          }.onDisappear {
            Task {
              await dismissImmersiveSpace()
            }
          }
        /*
        RealityView { content in
            makeHandEntities(in: content)
        }
         */
    }

    /*
    /// Creates the entity that contains all hand-tracking entities.
    @MainActor
    func makeHandEntities(in content: any RealityViewContentProtocol) {
        print("adding hand entities")
        // Add the left hand.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)

        // Add the right hand.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
    }
     */
}

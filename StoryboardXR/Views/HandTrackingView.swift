//
//  HandTrackingView.swift
//  StoryboardXR
//
//  Created by Dalton Brockett on 3/15/25.
//

import SwiftUI
import RealityKit
import ARKit

/// Main view for hand tracking state
struct HandTrackingView: View {
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
              await openImmersiveSpace(id: "HandTrackingRealityView")
            }
            
          }.onDisappear {
            Task {
              await dismissImmersiveSpace()
            }
          }
    }
}

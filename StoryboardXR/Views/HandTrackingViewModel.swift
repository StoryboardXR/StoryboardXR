//
//  HandTrackingViewModel.swift
//  StoryboardXR
//
//  Created by Dalton Brockett on 3/5/25.
//
// Privacy
// Authorization
import RealityKit
import ARKit
import RealityKitContent
import SwiftUI

@MainActor class HandTrackingViewModel: ObservableObject {
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    private let sceneReconstruction = SceneReconstructionProvider()
    
    private var contentEntity = Entity()
    
    private let meshEntities = [UUID : ModelEntity]()
    
    private let fingerEntities: [HandAnchor.Chirality : ModelEntity] = [
        .left: .createFingertip()
    ]
    
}

/*
private let session = ARKitSession()

Task {
    let authorizationResult = await session.requestAuthorization(for: [.handTracking])

    for (authorizationType, authorizationStatus) in authorizationResult {
        print("Authorization status for \(authorizationType): \(authorizationStatus)")

        switch authorizationStatus {
        case .allowed:
            // All good!
            break
        case .denied:
            // Need to handle this.
            break
        }
    }
}
*/

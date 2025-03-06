//
//  HandTracking.swift
//  StoryboardXR
//
//  Created by Dalton Brockett on 3/4/25.
//
// testing setup

// Privacy
// Authorization
import RealityKit
import ARKit
import RealityKitContent


@MainActor class 
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

//
//  HandTrackingSystem.swift
//  StoryboardXR
//
//  Created by Dalton Brockett on 3/15/25.
//

import RealityKit
import ARKit
import SwiftUICore
import UIKit

extension Notification.Name {
    static let shouldPlaceFrame = Notification.Name("shouldPlaceFrame")
    static let couldPlaceFrame = Notification.Name("couldPlaceFrame")
}

extension HandTrackingSystem {
    static var currentLeftHand: HandAnchor? { return latestLeftHand }
    static var currentRightHand: HandAnchor? { return latestRightHand }
}


/// A system that provides hand-tracking capabilities.
struct HandTrackingSystem: System {
    /// The active ARKit session.
    private static var arSession = ARKitSession()

    /// The provider instance for hand-tracking.
    private static let handTracking = HandTrackingProvider()

    /// The most recent anchor that the provider detects on the left hand.
    private static var latestLeftHand: HandAnchor?

    /// The most recent anchor that the provider detects on the right hand.
    private static var latestRightHand: HandAnchor?
    
    // The tracker for if L shape is engaged
    static var LGestureDetected: Bool = false
    
    private static var LGestureChirality: HandAnchor.Chirality? = nil
    
    private static var LTapGestureReleased: Bool = true
    
    //static var framePlacementManager = FramePlacementManager()
    
    
    private let scene: Scene

    init(scene: RealityKit.Scene) {
        self.scene = scene
        Task { await Self.runSession() }
    }

    @MainActor
    static func runSession() async {
        do {
            // Attempt to run the ARKit session with the hand-tracking provider.
            try await arSession.run([handTracking])
        } catch let error as ARKitSession.Error {
            print("The app has encountered an error while running providers: \(error.localizedDescription)")
        } catch let error {
            print("The app has encountered an unexpected error: \(error.localizedDescription)")
        }

        // Start to collect each hand-tracking anchor.
        for await anchorUpdate in handTracking.anchorUpdates {
            let anchor = anchorUpdate.anchor

            switch anchor.chirality {
            case .left:
                self.latestLeftHand = anchor
            case .right:
                self.latestRightHand = anchor
            }
        }

    }
    
    /// The query this system uses to find all entities with the hand-tracking component.
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    /// Performs any necessary updates to the entities with the hand-tracking component.
    /// - Parameter context: The context for the system to update.
    func update(context: SceneUpdateContext) {
        let handEntities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

        for entity in handEntities {
            guard var handComponent = entity.components[HandTrackingComponent.self] else { continue }

            // Set up the finger joint entities if you haven't already.
            if handComponent.fingers.isEmpty {
                self.addJoints(to: entity, handComponent: &handComponent)
            }

            // Get the hand anchor for the component, depending on its chirality.
            guard let handAnchor: HandAnchor = switch handComponent.chirality {
                case .left: Self.latestLeftHand
                case .right: Self.latestRightHand
                default: nil
            } else { continue }
            

            // Iterate through all of the anchors on the hand skeleton.
            if let handSkeleton = handAnchor.handSkeleton {
                
                //L shaped gesture computation
                // check to see if vector of hand joint 4 - 1 is orthogonal to 9 - 5
                let joint1Transform = handSkeleton.joint(.thumbKnuckle).anchorFromJointTransform
                let joint4Transform = handSkeleton.joint(.thumbTip).anchorFromJointTransform
                let joint5Transform = handSkeleton.joint(.indexFingerMetacarpal).anchorFromJointTransform
                let joint9Transform = handSkeleton.joint(.indexFingerTip).anchorFromJointTransform

                let pos1 = position(from: joint1Transform)
                let pos4 = position(from: joint4Transform)
                let pos5 = position(from: joint5Transform)
                let pos9 = position(from: joint9Transform)
                
                let vectorA = pos4 - pos1   // For example: from thumb knuckle to thumb tip.
                let vectorB = pos9 - pos5   // For example: from index finger metacarpal to index finger tip.
                //print("Vector A: \(vectorA)")
                //print("Vector B: \(vectorB)")

                let normalizedA = simd_normalize(vectorA)
                let normalizedB = simd_normalize(vectorB)
                
                let dotProduct = simd_dot(normalizedA, normalizedB)
                //print("Dot Product: \(dotProduct)")

                // Compute the angle between the vectors (in degrees).
                let angleRadians = acos(dotProduct)
                let angleDegrees = angleRadians * 180 / .pi
                //print("Angle in degrees: \(angleDegrees)")

                // Check for orthogonality with a tolerance.
                let epsilon: Float = 0.1
                let degreeMargin: Float = 55.0
                if abs(angleDegrees) > degreeMargin {
                    //print("Vectors are \"orthogonal\" (L-shape detected).")
                    //print(handAnchor.chirality.description)
                    Self.LGestureDetected = true
                    Self.LGestureChirality = handAnchor.chirality
                    
                    // Identify the other hand (opposite chirality).
                    let lChirality = Self.LGestureChirality
                    let otherHandAnchor: HandAnchor? = (lChirality == .left) ? Self.latestRightHand : Self.latestLeftHand
                    let tapGestureDetect = isTapGestureDetected(for: otherHandAnchor!)
                    if tapGestureDetect && Self.LTapGestureReleased && Self.LGestureDetected{
                        //add frame object
                        //placeFrame(inFrontOf: lChirality!)
                        //Self.framePlacementManager.shouldPlaceFrame = true
                        placeFrame(inFrontOf: lChirality!)
                        Self.LTapGestureReleased = false
                        Self.LGestureChirality = nil
                        print("Should be placing a frame now, but only once before releasing the tap hopefully")
                    } else if !tapGestureDetect && !Self.LTapGestureReleased{
                        Self.LTapGestureReleased = true
                        print("tap is released!")
                    } else if Self.LGestureDetected && !tapGestureDetect{
                        NotificationCenter.default.post(name: .couldPlaceFrame, object: lChirality!)
                        
                        //Set thumb and finger tips to green indicating L shape
                        if let thumbTipEntity = handComponent.fingers[.thumbTip],
                           let indexFingerTipEntity = handComponent.fingers[.indexFingerTip],
                           var thumbModelComponent = thumbTipEntity.components[ModelComponent.self],
                           var indexFingerModelComponent = indexFingerTipEntity.components[ModelComponent.self],
                           var simpleMaterial = thumbModelComponent.materials.first as? SimpleMaterial {
                            
                            // Update the material’s tint to have full opacity (alpha = 1.0)
                            simpleMaterial.color = .init(tint: simpleMaterial.color.tint.withAlphaComponent(1.0),
                                                           texture: simpleMaterial.color.texture)
                            
                            // Replace the first material with the updated one
                            thumbModelComponent.materials[0] = simpleMaterial
                            indexFingerModelComponent.materials[0] = simpleMaterial
                            
                            // Update the entity’s ModelComponent
                            thumbTipEntity.components.set(thumbModelComponent)
                            indexFingerTipEntity.components.set(indexFingerModelComponent)
                        }
                        
                        print("hopefully L should have some visual cue")
                    }
                } else {
                    //print("Vectors are not \"orthogonal\".")
                    Self.LGestureDetected = false
                    Self.LGestureChirality = nil
                    //Set thumb and finger tips to green indicating L shape
                    if let thumbTipEntity = handComponent.fingers[.thumbTip],
                       let indexFingerTipEntity = handComponent.fingers[.indexFingerTip],
                       var thumbModelComponent = thumbTipEntity.components[ModelComponent.self],
                       var indexFingerModelComponent = indexFingerTipEntity.components[ModelComponent.self],
                       var simpleMaterial = thumbModelComponent.materials.first as? SimpleMaterial {
                        
                        // Update the material’s tint to have full opacity (alpha = 1.0)
                        simpleMaterial.color = .init(tint: simpleMaterial.color.tint.withAlphaComponent(0.0),
                                                       texture: simpleMaterial.color.texture)
                        
                        // Replace the first material with the updated one
                        thumbModelComponent.materials[0] = simpleMaterial
                        indexFingerModelComponent.materials[0] = simpleMaterial
                        
                        // Update the entity’s ModelComponent
                        thumbTipEntity.components.set(thumbModelComponent)
                        indexFingerTipEntity.components.set(indexFingerModelComponent)
                    }
                    
                }
                
                for (jointName, jointEntity) in handComponent.fingers {
                    /// The current transform of the person's hand joint.
                    let anchorFromJointTransform = handSkeleton.joint(jointName).anchorFromJointTransform
                    
                    //testing standard offset; eventually to be for translating/adjusting frame entities
                    //var testOffsetLeft = Transform(translation: SIMD3<Float>(0.05,0.05,0.05)).matrix
                    //var testOffsetRight = Transform(translation: SIMD3<Float>(0.05,0.05,-0.05)).matrix
                    var testOffsetLeft = Transform(translation: SIMD3<Float>(0.0,0.0,0.0)).matrix
                    var testOffsetRight = Transform(translation: SIMD3<Float>(0.0,0.0,-0.0)).matrix
                
                    // Update the joint entity to match the transform of the person's hand joint.
                    
                    if (handComponent.chirality == .left) {
                        jointEntity.setTransformMatrix(
                            handAnchor.originFromAnchorTransform * testOffsetLeft * anchorFromJointTransform,
                            relativeTo: nil
                        )
                    } else {
                        //right hand coordinate adjustment for tranlations
                        testOffsetRight.columns.3.x *= -1.0
                        testOffsetRight.columns.3.y *= -1.0
                        jointEntity.setTransformMatrix(
                            handAnchor.originFromAnchorTransform * testOffsetRight * anchorFromJointTransform,
                            relativeTo: nil
                        )
                    }
                }
            }
        }
    }
    
    /// Performs any necessary setup to the entities with the hand-tracking component.
    /// - Parameters:
    ///   - entity: The entity to perform setup on.
    ///   - handComponent: The hand-tracking component to update.
    func addJoints(to handEntity: Entity, handComponent: inout HandTrackingComponent) {
        /// The size of the sphere mesh.
        let radius: Float = 0.01

        /// The material to apply to the sphere entity.
        //let material = SimpleMaterial(color: .purple, isMetallic: false)
        var material = SimpleMaterial()
        material.color =  .init(tint: UIColor.green.withAlphaComponent(0.0), texture: nil)

        /// The sphere entity that represents a joint in a hand.
        let sphereEntity = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [material]
        )

        // For each joint, create a sphere and attach it to the fingers.
        
        for bone in Hand.joints {
            let newJoint: Entity
            // Check if the joint is thumbTip or indexTip
            if bone.0 == .thumbTip || bone.0 == .indexFingerTip {
                // For thumbTip and indexFingerTip, use the sphere model.
                newJoint = sphereEntity.clone(recursive: false)
            } else {
                // For all other joints, just create an empty entity.
                newJoint = Entity()
            }
            print(newJoint.name)
            handEntity.addChild(newJoint)

            // Attach the sphere to the finger.
            print(bone.0)
            handComponent.fingers[bone.0] = newJoint
        }
         

        // Apply the updated hand component back to the hand entity.
        handEntity.components.set(handComponent)
    }
    
    // Helper function to extract translation from a transform matrix.
    func position(from transform: simd_float4x4) -> SIMD3<Float> {
        return SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }

    /// Checks if the given hand anchor is performing a tap gesture.
    /// For example, this implementation checks if the distance between the index finger tip and thumb tip is below a threshold.
    private func isTapGestureDetected(for handAnchor: HandAnchor) -> Bool {
        guard let handSkeleton = handAnchor.handSkeleton else { return false }
        let indexTipPos = position(from: handSkeleton.joint(.indexFingerTip).anchorFromJointTransform)
        let thumbTipPos = position(from: handSkeleton.joint(.thumbTip).anchorFromJointTransform)
        let distance = simd_distance(indexTipPos, thumbTipPos)
        // Define a threshold (in meters); adjust as needed.
        return distance < 0.01
    }
    

    // Sends notification to HandTrackingView to prace frame object
    @MainActor
    func placeFrame(inFrontOf chirality: HandAnchor.Chirality){
        NotificationCenter.default.post(name: .shouldPlaceFrame, object: chirality)
    }
}

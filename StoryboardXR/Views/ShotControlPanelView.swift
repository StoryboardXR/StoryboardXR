//
//  ShotControlPanelView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

import SwiftUI
import simd

struct ShotControlPanelView: View {
  // MARK: Environment.
  @Environment(AppModel.self) private var appModel
  @Bindable var shotModel: ShotModel

  // MARK: Properties.
  private var rotationBinding: Binding<simd_double3> {
    Binding(
      get: { shotModel.rotation.eulerAngles(order: .xyz).angles },
      set: {
        shotModel.rotation = Rotation3D(
          eulerAngles: EulerAngles(angles: $0, order: .xyz))
      }
    )
  }

  @FocusState private var notesFocused: Bool

  // MARK: View.
  var body: some View {
    Form {
      Stepper {
        Text("Shot \(appModel.sceneNumber)\(shotModel.name)").font(.largeTitle)
      } onIncrement: {
        incrementShotName()
      } onDecrement: {
        decrementShotName()
      }

      Section(header: Text("Orientation")) {
        Grid {
          // Position.
          GridRow {
            Text("Position:")
              .gridColumnAlignment(.trailing)
            TextField(
              "X", value: $shotModel.position.x,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Y", value: $shotModel.position.y,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Z", value: $shotModel.position.z,
              format: FloatingPointFormatStyle()
            )
          }

          // Rotation.
          GridRow {
            Text("Rotation:")
              .gridColumnAlignment(.trailing)
            TextField(
              "X", value: rotationBinding.x,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Y", value: rotationBinding.y,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Z", value: rotationBinding.z,
              format: FloatingPointFormatStyle()
            )
          }

          // Scale.
          GridRow {
            Text("Scale:")
              .gridColumnAlignment(.trailing)
            TextField(
              "X", value: $shotModel.scale.x,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Y", value: $shotModel.scale.y,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Z", value: $shotModel.scale.z,
              format: FloatingPointFormatStyle()
            )
          }
        }
        .disabled(shotModel.orientationLock)
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.center)
        .textFieldStyle(.roundedBorder)

        Toggle("Lock", isOn: $shotModel.orientationLock)
      }

      Section(header: Text("Notes")) {
        TextEditor(text: $shotModel.notes)
          .textFieldStyle(.roundedBorder)
      }
    }
    .padding()
    .frame(width: 500, height: 500)
    .glassBackgroundEffect()
  }

  // MARK: Helper functions.

  /// Get all available shot names including this one.
  var unusedShotNames: [ShotName] {
    // Generate list of shot names.
    let currentShotName = shotModel.name
    let usedNames: Set = Set(
      appModel.shots.compactMap { shotModel in shotModel.name })
    return ShotName.allCases.filter { name in
      name == currentShotName || !usedNames.contains(name)
    }
  }

  /// Set shot name to the next lexigraphically available one.
  func incrementShotName() {
    shotModel.name =
      unusedShotNames[
        (unusedShotNames.firstIndex(of: shotModel.name)! + 1)
          % unusedShotNames.count]
  }

  /// Set shot name to the previous lexigraphically available one.
  func decrementShotName() {
    shotModel.name =
      unusedShotNames[
        (unusedShotNames.firstIndex(of: shotModel.name)! - 1)
          % unusedShotNames.count]
  }
}

#Preview(windowStyle: .plain) {
  let appModel = AppModel()
  ShotControlPanelView(shotModel: appModel.shots[0])
    .environment(appModel)
}

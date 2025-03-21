//
//  ShotControlPanelView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

import SwiftUI
import simd

struct ShotControlPanelView: View {
  // MARK: Environment
  @Environment(AppModel.self) private var appModel
  @Bindable var shotModel: ShotModel

  // MARK: Properties
  private var rotationBinding: Binding<simd_double3> {
    Binding(
      get: {
        Rotation3D(shotModel.transform.rotation).eulerAngles(order: .xyz).angles * 180 / .pi
      },
      set: {
        shotModel.transform.rotation = simd_quatf(
          Rotation3D(eulerAngles: EulerAngles(angles: $0 * .pi / 180, order: .xyz)))
      }
    )
  }

  @FocusState private var notesFocused: Bool

  // MARK: View
  var body: some View {
    Form {
      Stepper {
        Text("Shot \(appModel.sceneNumber)\(shotModel.name)").font(.largeTitle)
      } onIncrement: {
        shotModel.incrementShotName()
      } onDecrement: {
        shotModel.decrementShotName()
      }

      Section(header: Text("Orientation")) {
        Grid {
          // Position.
          GridRow {
            Text("Position:")
              .gridColumnAlignment(.trailing)
            TextField(
              "X", value: $shotModel.transform.translation.x,
              format: .number.precision(.fractionLength(2))
            )
            TextField(
              "Y", value: $shotModel.transform.translation.y,
              format: .number.precision(.fractionLength(2))
            )
            TextField(
              "Z", value: $shotModel.transform.translation.z,
              format: .number.precision(.fractionLength(2))
            )
          }

          // Rotation.
          GridRow {
            Text("Rotation:")
              .gridColumnAlignment(.trailing)
            TextField(
              "X", value: rotationBinding.x,
              format: .number.precision(.fractionLength(1))
            )
            TextField(
              "Y", value: rotationBinding.y,
              format: .number.precision(.fractionLength(1))
            )
            TextField(
              "Z", value: rotationBinding.z,
              format: .number.precision(.fractionLength(1))
            )
          }

          // Scale.
          GridRow {
            Text("Scale:")
              .gridColumnAlignment(.trailing)
            TextField(
              "X", value: $shotModel.transform.scale.x,
              format: .number.precision(.fractionLength(2))
            )
            TextField(
              "Y", value: $shotModel.transform.scale.y,
              format: .number.precision(.fractionLength(2))
            )
            TextField(
              "Z", value: $shotModel.transform.scale.z,
              format: .number.precision(.fractionLength(2))
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

      Button("Remove Shot", role: .destructive) {
        appModel.shots.removeAll(where: { $0.name == shotModel.name })
      }
    }
    .padding()
    .frame(width: 500, height: 500)
    .glassBackgroundEffect()
  }
}

#Preview(windowStyle: .plain) {
  let appModel = AppModel()
  ShotControlPanelView(shotModel: ShotModel(appModel: appModel))
    .environment(appModel)
}

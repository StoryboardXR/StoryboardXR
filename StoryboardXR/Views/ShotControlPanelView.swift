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
      get: { shotModel.rotation.eulerAngles(order: .xyz).angles },
      set: {
        shotModel.rotation = Rotation3D(
          eulerAngles: EulerAngles(angles: $0, order: .xyz))
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
}

#Preview(windowStyle: .plain) {
  let appModel = AppModel()
  ShotControlPanelView(shotModel: appModel.shots[0])
    .environment(appModel)
}

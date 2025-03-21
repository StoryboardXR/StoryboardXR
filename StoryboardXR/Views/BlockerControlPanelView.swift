//
//  BlockerControlPanelView.swift
//  StoryboardXR
//
//  Created by Marley Byers on 3/20/25.
//

import SwiftUI
import simd

struct BlockerControlPanelView: View {
  // MARK: Environment
  @Environment(AppModel.self) private var appModel
  @Bindable var blockerModel: BlockerModel

  // MARK: Properties
  private var rotationBinding: Binding<simd_double3> {
    Binding(
      get: {
        Rotation3D(blockerModel.transform.rotation).eulerAngles(order: .xyz).angles
      },
      set: {
        blockerModel.transform.rotation = simd_quatf(
          Rotation3D(eulerAngles: EulerAngles(angles: $0, order: .xyz)))
      }
    )
  }

  @FocusState private var notesFocused: Bool

  // MARK: View
  var body: some View {
    Form {
      TextField("Name", text: $blockerModel.name)

      Section(header: Text("Orientation")) {
        Grid {
          // Position.
          GridRow {
            Text("Position:")
              .gridColumnAlignment(.trailing)
            TextField(
              "X", value: $blockerModel.transform.translation.x,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Y", value: $blockerModel.transform.translation.y,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Z", value: $blockerModel.transform.translation.z,
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
              "X", value: $blockerModel.transform.scale.x,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Y", value: $blockerModel.transform.scale.y,
              format: FloatingPointFormatStyle()
            )
            TextField(
              "Z", value: $blockerModel.transform.scale.z,
              format: FloatingPointFormatStyle()
            )
          }
        }
        .disabled(blockerModel.orientationLock)
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.center)
        .textFieldStyle(.roundedBorder)

        Toggle("Lock", isOn: $blockerModel.orientationLock)
      }

      Section(header: Text("Notes")) {
        TextEditor(text: $blockerModel.notes)
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
  BlockerControlPanelView(blockerModel: BlockerModel(appModel: appModel))
    .environment(appModel)
}

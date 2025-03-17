//
//  ShotControlPanelView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

import SwiftUI

struct ShotControlPanelView: View {
  // MARK: Environment.
  @Environment(AppModel.self) private var appModel
  @Bindable var shotModel: ShotModel

  // MARK: Properties.
  @State private var positionXInput: String = ""
  @State private var positionYInput: String = ""
  @State private var positionZInput: String = ""

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
        Toggle(
          "Position", isOn: $shotModel.lockPosition)
        HStack {
          TextField("X", text: $positionXInput)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .onAppear {
              positionXInput = String(shotModel.position.x)
            }
            .onChange(of: positionXInput) { _, newValue in
              if let value = Float(newValue) {
                shotModel.position.x = value
              }
            }
          TextField("Y", text: $positionYInput)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .onAppear {
              positionYInput = String(shotModel.position.y)
            }
            .onChange(of: positionYInput) { _, newValue in
              if let value = Float(newValue) {
                shotModel.position.y = value
              }
            }
          TextField("Z", text: $positionZInput)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .onAppear {
              positionZInput = String(shotModel.position.z)
            }
            .onChange(of: positionZInput) { _, newValue in
              if let value = Float(newValue) {
                shotModel.position.z = value
              }
            }
        }
        .disabled(shotModel.lockPosition)
        .opacity(shotModel.lockPosition ? 0.7 : 1.0)
      }
    }
    .padding()
    .frame(width: 400, height: 500)
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

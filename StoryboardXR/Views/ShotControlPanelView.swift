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

  var body: some View {
    VStack {
      Text("Shot \(appModel.sceneNumber)\(shotModel.name)").font(
        .largeTitle)

      List {
        Picker("Shot Name", selection: $shotModel.name) {
          ForEach(ShotName.allCases) { name in
            Text("\(name)")
              .tag(name)
          }
        }
        .pickerStyle(.palette)

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

    }
    .padding()
    .frame(width: 400, height: 500)
    .background(.regularMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .shadow(radius: 5)
  }
}

#Preview(windowStyle: .plain) {
  let appModel = AppModel()
  ShotControlPanelView(shotModel: appModel.shots[0])
    .environment(appModel)
}

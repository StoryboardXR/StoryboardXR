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

  // MARK: Properties.
  let shotIndex: Int
  @FocusState private var notesFocused: Bool
  private var shotModel: Binding<ShotModel> {
    Binding(
      get: { appModel.shots[shotIndex] },
      set: { appModel.shots[shotIndex] = $0 })
  }

  var body: some View {
    VStack {
      Text("Shot \(appModel.sceneNumber)\(shotModel.name)").font(
        .largeTitle)

      Form {
        Picker("Shot Name", selection: shotModel.name) {
          ForEach(ShotName.allCases) { name in
            Text("\(name)")
              .tag(name)
          }
        }

        Section(header: Text("Orientation")) {
          Toggle(
            "Translation", isOn: shotModel.enableTranslation)
        }
      }

      // Interaction locker.
      //      Text("Locks").font(.title)
      //      Toggle("Translation", isOn: $enableTranslation)
      //      Toggle("Rotation", isOn: $enableRotation)
      //      Toggle("Scale", isOn: $enableScale)
      //
      //      // Extra notes.
      //      TextEditor(text: $notes)
      //        .focused($notesFocused)
      //      Button("Save") {
      //        notesFocused = false
      //      }
    }
    .padding()
    .frame(width: 400, height: 500)
    .background(.regularMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .shadow(radius: 5)
  }
}

#Preview(windowStyle: .plain) {
  ShotControlPanelView(shotIndex: 0)
    .environment(AppModel())
}

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
  let dataIndex: Int
  @State private var shotName: ShotName = .a
  @State private var enableTranslation: Bool = true
  @State private var enableRotation: Bool = true
  @State private var enableScale: Bool = true
  @State private var notes: String = ""
  @FocusState private var notesFocused: Bool

  var body: some View {
    VStack {
      // Shot name.
      HStack{
        Text("Shot \(appModel.sceneNumber)").font(.largeTitle)
        Picker("", selection: $shotName) {
          ForEach(ShotName.allCases) { name in
            Text("\(name)")
              .tag(name)
          }
        }
      }
      
      // Interaction locker.
      Text("Locks").font(.title)
      Toggle("Translation", isOn: $enableTranslation)
      Toggle("Rotation", isOn: $enableRotation)
      Toggle("Scale", isOn: $enableScale)
      
      // Extra notes.
      TextEditor(text: $notes)
        .focused($notesFocused)
      Button("Save") {
        notesFocused = false
      }
    }
    .padding()
  }
}

#Preview(windowStyle: .automatic) {
  ShotControlPanelView(dataIndex: 0)
    .environment(AppModel())
}

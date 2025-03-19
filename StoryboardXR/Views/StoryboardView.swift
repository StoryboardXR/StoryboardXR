//
//  StoryboardView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/4/25.
//

import SwiftUI

struct StoryboardView: View {
  // MARK: Environment
  @Environment(AppModel.self) private var appModel
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

  // MARK: Properties
  private var sceneNumberBinding: Binding<Int> {
    Binding(
      get: { appModel.sceneNumber },
      set: { appModel.sceneNumber = $0 }
    )
  }
  @State private var showSaveAlert = false

  var body: some View {
    VStack {
      Text("Storyboard View").font(.largeTitle)

      HStack {
        Stepper(value: sceneNumberBinding, in: 1...1000) {
          Text("Shot Number: \(appModel.sceneNumber)").font(.title)
        }

        Button("Save") {
          showSaveAlert = true
        }
      }
      .padding()

      Button("Add Frame") {
        appModel.shots.append(ShotModel(appModel: appModel))
      }

      Divider()

      Button("Switcher") {
        appModel.featureMode = .switcher
      }
    }
    .padding()
    .frame(width: 500, height: 500)
    .alert("Save Scene?", isPresented: $showSaveAlert) {
      Button("Save", role: .destructive) {
        print("Saved!")
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Saving a scene overwrites any scene with the same number.")
    }

    // MARK: Immersive space handler
    .onAppear {
      Task {
        await openImmersiveSpace(id: STORYBOARD_SPACE_ID)
      }
    }.onDisappear {
      Task {
        await dismissImmersiveSpace()
      }
    }
  }
}

#Preview(windowStyle: .automatic) {
  StoryboardView().environment(AppModel())
}

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
  @State private var loadedScene: URL?

  var body: some View {
    VStack {
      Text("Storyboard View").font(.largeTitle)

      Stepper(value: sceneNumberBinding, in: 1...1000) {
        Text("Shot Number: \(appModel.sceneNumber)").font(.title)
      }
      .padding()

      HStack {
        Button("Save") {
          showSaveAlert = true
        }
        Button("Load") {
          let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask)
          let filePath = documentsDirectory.first?.appendingPathComponent(
            "Scene_\(appModel.sceneNumber).json")

          guard let filePath,
            FileManager.default.fileExists(
              atPath: filePath.path(percentEncoded: true))
          else {
            print("Scene slot has not been used yet!")
            return
          }

          loadedScene = filePath

          do {
            let data = try Data(contentsOf: filePath)
            appModel.shots = try JSONDecoder().decode(
              [ShotModel].self, from: data)
          } catch {
            print("Failed to decode scene! \(error)")
          }
        }
      }

      Divider()

      Button("Add Frame") {
        appModel.shots.append(ShotModel(appModel: appModel))
      }

      Divider()

      if let loadedScene = loadedScene {
        ShareLink("Share Scene", item: loadedScene)
        
        Divider()
      }

      Button("Switcher") {
        appModel.featureMode = .switcher
      }
    }
    .padding()
    .frame(width: 500, height: 500)
    .alert("Save Scene?", isPresented: $showSaveAlert) {
      Button("Save", role: .destructive) {
        do {
          // Encode.
          let encoding = try JSONEncoder().encode(appModel.shots)

          // Get save location.
          let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask)[0]
          let filePath = documentsDirectory.appendingPathComponent(
            "Scene_\(appModel.sceneNumber).json")

          // Save.
          try encoding.write(to: filePath)
        } catch {
          print("Unable to encode! \(error)")
        }
      }

      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Saving a scene overwrites any scene with the same number.")
    }
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

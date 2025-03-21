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
      set: {
        appModel.sceneNumber = $0

        // Unset loaded scene.
        loadedScene = nil
      }
    )
  }
  @State private var showSaveAlert = false
  @State private var loadedScene: URL?
  @State private var blockerName: String = ""
  @State private var showBlockerNamingAlert = false

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
          
          let shotFilePath = documentsDirectory.first?.appendingPathComponent(
            "Scene_\(appModel.sceneNumber)/\(SHOT_FRAME_ENTITY_NAME).json")
          
          let blockerFilePath = documentsDirectory.first?.appendingPathComponent(
            "Blocker_\(appModel.sceneNumber)/\(BLOCKER_ENTITY_NAME).json")

          guard let shotFilePath,
            FileManager.default.fileExists(
              atPath: shotFilePath.path(percentEncoded: true))
          else {
            print("Scene slot has not been used yet!")
            return
          }
          
          guard let blockerFilePath,
            FileManager.default.fileExists(
              atPath: blockerFilePath.path(percentEncoded: true))
          else {
            print("Scene slot has not been used with blockers yet!")
            return
          }
          // If you want to use this you should figure out if it works with
          // the nested folders for blockers and shots and if not, combine them
          
          do {
            let shotData = try Data(contentsOf: shotFilePath)
            appModel.shots = try JSONDecoder().decode(
              [ShotModel].self, from: shotData)
            
            let blockerData = try Data(contentsOf: blockerFilePath)
            appModel.blockers = try JSONDecoder().decode(
              [BlockerModel].self, from: blockerData)

            // Remember data file.
            loadedScene = shotFilePath

            // Mark changes saved.
            appModel.unsavedChanges = false
          } catch {
            print("Failed to decode scene! \(error)")
          }
        }
      }

      Divider()

      Button("Add Frame") {
        appModel.shots.append(ShotModel(appModel: appModel))
      }
      
      // New "Add Model" button that shows an options dialog
      Button("Add Blocker") {
        showBlockerNamingAlert = true
      }

      Divider()

      if let loadedScene = loadedScene {
        ShareLink("Share Scene", item: loadedScene)
          .disabled(appModel.unsavedChanges)

        if appModel.unsavedChanges {
          Text("Save changes before sharing!")
        }

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
          let encodingShots = try JSONEncoder().encode(appModel.shots)
          let encodingBlockers = try JSONEncoder().encode(appModel.blockers)
          

          // Get save location.
          let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask)[0]
          
          let shotFilePath = documentsDirectory.appendingPathComponent(
            "Scene_\(appModel.sceneNumber)/\(SHOT_FRAME_ENTITY_NAME).json")
          
          let blockerFilePath = documentsDirectory.appendingPathComponent(
            "Blocker_\(appModel.sceneNumber)/\(BLOCKER_ENTITY_NAME).json")

          // Save.
          try encodingShots.write(to: shotFilePath)
          try encodingBlockers.write(to: blockerFilePath) // Might mess up shot encoding so i'm not messing with it yet

          // Remember data file.
          loadedScene = shotFilePath

          // Mark changes saved.
          appModel.unsavedChanges = false
        } catch {
          print("Unable to encode! \(error)")
        }
      }

      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Saving a scene overwrites any scene with the same number.")
    }
    .alert("Name Your Blocker", isPresented: $showBlockerNamingAlert) {
      TextField("Blocker Name", text: $blockerName)
      Button("Add") {
        guard !blockerName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        appModel.blockers.append(BlockerModel(appModel: appModel, name: blockerName))
        blockerName = ""
      }
      Button("Cancel", role: .cancel) {}
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

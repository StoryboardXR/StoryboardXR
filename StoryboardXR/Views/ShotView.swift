//
//  ShotView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

import SwiftUI

struct ShotView: View {
  // MARK: Environment.
  @Environment(AppModel.self) private var appModel

  // MARK: Properties.
  let dataIndex: Int
  @State private var shotName: ShotName = .a

  var body: some View {
    VStack {
      // Shot name.
      HStack{
        Text("Shot \(appModel.sceneNumber)").font(.title)
        Picker("", selection: $shotName) {
          ForEach(ShotName.allCases) { name in
            Text("\(name)").tag(name)
          }
        }
      }
      
      // Interaction switcher.
    }
    .padding()
  }
}

#Preview(windowStyle: .automatic) {
  ShotView(dataIndex: 0)
    .environment(AppModel())
}

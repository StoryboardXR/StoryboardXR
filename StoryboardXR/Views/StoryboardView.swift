//
//  StoryboardView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/4/25.
//

import SwiftUI

struct StoryboardView: View {
  @Environment(AppModel.self) private var appModel
  var body: some View {
    VStack {
      Text("Storyboard View").font(.title)
      Button("Switcher") {
        appModel.featureMode = .switcher
      }
    }.padding()
  }
}

#Preview {
  StoryboardView()
}

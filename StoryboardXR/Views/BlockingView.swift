//
//  BlockingView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/4/25.
//

import SwiftUI

struct BlockingView: View {
  @Environment(AppModel.self) private var appModel
  var body: some View {
    VStack {
      Text("Blocking View").font(.title)
      Button("Switcher") {
        appModel.featureMode = .switcher
      }
    }.padding()
  }
}

#Preview {
  BlockingView()
}

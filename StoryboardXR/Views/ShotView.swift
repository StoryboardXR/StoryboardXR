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
  let frameIndex: Int

  var body: some View {
    VStack {
      
    }
    .padding()
  }
}

#Preview(windowStyle: .automatic) {
  ShotView(frameIndex: 0)
    .environment(AppModel())
}

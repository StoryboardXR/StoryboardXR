//
//  HandTrackingView.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/4/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct HandTrackingView: View {
  @Environment(AppModel.self) private var appModel
    @StateObject var model = HandTrackingViewMOdel()
  var body: some View {
    VStack {
      Text("Hand Tracking View").font(.title)
      Button("Switcher") {
        appModel.featureMode = .switcher
      }
    }.padding()
      
      RealityView{ content in
      } .task{
          
      } .task{
          
      } .task{
          
      }
  }
}

#Preview {
  HandTrackingView()
}

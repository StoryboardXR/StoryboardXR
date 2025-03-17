//
//  ShotModel.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

import Foundation

struct ShotModel: Identifiable {
  var id = UUID()
  
  var name: ShotName = .a
  var enableTranslation: Bool = true
  var enableRotation: Bool = true
  var enableScale: Bool = true
  
  var notes: String = ""
}

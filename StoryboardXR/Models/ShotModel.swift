//
//  ShotModel.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

struct ShotModel: Identifiable {
  var id: String
  
  var enableTranslation: Bool = true
  var enableRotation: Bool = true
  var enableScale: Bool = true
  
  var notes: String = ""
}

//
//  Constants.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

let STORYBOARD_SPACE_ID = "StoryboardSpace"
let SHOT_CONTROL_PANEL_ATTACHMENT_ID = "ShotControlPanelAttachment"

/// Shot identifying name.
enum ShotName: String, CaseIterable, CustomStringConvertible, Identifiable {
  case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x,
    y, z

  var id: Self { self }

  var description: String {
    return self.rawValue.uppercased()
  }
}



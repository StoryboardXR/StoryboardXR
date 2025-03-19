//
//  Constants.swift
//  StoryboardXR
//
//  Created by Kenneth Yang on 3/16/25.
//

// MARK: ID's
let STORYBOARD_SPACE_ID = "StoryboardSpace"
let SHOT_CONTROL_PANEL_ATTACHMENT_ID = "ShotControlPanelAttachment"

// MARK: Names
let SHOT_FRAME_ENTITY_NAME = "ShotFrame"
let ORIGIN_ENTITY_NAME = "Origin"

/// Shot identifying name.
enum ShotName: String, CaseIterable, CustomStringConvertible, Identifiable {
  case unnamed, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u,
    v, w, x, y, z

  var id: Self { self }

  var description: String {
    return self.rawValue.uppercased()
  }
}

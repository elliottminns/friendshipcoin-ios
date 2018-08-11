//
//  SettingSectionViewModel.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 19/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct SettingSectionViewModel {
  let settings: [Setting]
  let title: String?
  
  var count: Int {
    return settings.count
  }
  
  init(settings: [Setting], title: String?) {
    self.settings = settings
    self.title = title
  }
  
  subscript(_ index: Int) -> Setting {
    return settings[index]
  }
}

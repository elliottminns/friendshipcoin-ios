//
//  FSCAddress.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct FSCAddress {
  let address: String
  
  let index: Int
  
  init(address: String, index: Int) {
    self.address = address
    self.index = index
  }
}

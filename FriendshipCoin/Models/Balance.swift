//
//  Balance.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 28/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct Balance {
  let address: String
  
  let sent: String
  
  let received: String
  
  let current: String
}

extension Balance: Hashable {
  var hashValue: Int {
    return address.hashValue
  }
  
  static func ==(lhs: Balance, rhs: Balance) -> Bool {
    return lhs.address == rhs.address
  }
}

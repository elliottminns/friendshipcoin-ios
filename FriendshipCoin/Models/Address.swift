//
//  Address.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct Address {
  
  var id: String { return address }
  
  let address: String
 
  let account: Account
  
  let index: Int
}

extension Address: Hashable {
  var hashValue: Int {
    return address.hashValue
  }
  
  static func ==(lhs: Address, rhs: Address) -> Bool {
    return lhs.address == rhs.address
  }
}

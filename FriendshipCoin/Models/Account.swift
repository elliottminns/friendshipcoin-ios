//
//  Account.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct Account {

  let publicKey: String
  
  let index: Int
  
  init(publicKey: String, index: Int) {
    self.publicKey = publicKey
    self.index = index
  }
}

extension Account: Hashable {
  
  var hashValue: Int {
    return publicKey.hashValue
  }
  
  static func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs.publicKey == rhs.publicKey
  }
}

extension Account {
  var totalBalance: String {
    return NetworkManager.shared.wallet.balance(for: self)
  }
}

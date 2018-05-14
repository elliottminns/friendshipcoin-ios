//
//  WalletDebit+Array.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 14/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

extension Sequence where Element == WalletDebit {
  var amount: UInt64 {
    return reduce(0) { (result: UInt64, debit: WalletDebit) -> UInt64 in
      return result + debit.amount
    }
  }
}

extension Sequence where Element == WalletCredit {
  var amount: UInt64 {
    return reduce(0) { (result: UInt64, debit: WalletCredit) -> UInt64 in
      return result + debit.amount
    }
  }
}

//
//  AccountTransactions.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 28/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct AccountTransaction {
  
  enum Direction {
    case `in`
    case out
  }
  
  let amount: String
  
  let direction: Direction
  
  let transaction: Transaction
  
  let account: Account
  
  let address: Address
  
  var time: Date {
    return transaction.time
  }
}

extension AccountTransaction: Comparable {
  static func <(lhs: AccountTransaction, rhs: AccountTransaction) -> Bool {
    return lhs.transaction < rhs.transaction
  }
  
  static func ==(lhs: AccountTransaction, rhs: AccountTransaction) -> Bool {
    return lhs.transaction == rhs.transaction && lhs.address == rhs.address
  }
}

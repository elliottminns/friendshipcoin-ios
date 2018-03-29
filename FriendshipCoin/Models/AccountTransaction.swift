//
//  AccountTransactions.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 28/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

enum TransactionDirection {
  case `in`
  case out
}

struct AccountTransaction {
  
  let amount: String
  
  let direction: TransactionDirection
  
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

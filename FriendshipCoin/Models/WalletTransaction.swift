//
//  WalletTransaction.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 01/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct WalletTransaction {
  
  enum Direction {
    case `in`
    case out
  }
  
  let direction: Direction
  
  let transaction: FSCTransaction
  
  var timestamp: UInt32 {
    return transaction.timestamp
  }
  
  var amount: UInt64
  
  var formattedAmount: String {
    return String(format: "%0.8f", Double(self.amount) * 1e-8)
  }

  var time: Date {
    return Date(timeIntervalSince1970: TimeInterval(timestamp))
  }
  
  init(credit: WalletCredit) {
    self.init(transaction: credit.transaction, direction: .in, amount: credit.amount)
  }
  
  init(debit: WalletDebit) {
    self.init(transaction: debit.transaction, direction: .out, amount: debit.transaction.inputsAmount)
  }
  
  init(transaction: FSCTransaction, direction: Direction, amount: UInt64) {
    TransactionManager.shared.add(transaction: transaction)
    self.direction = direction
    self.transaction = transaction
    self.amount = amount
  }
}

extension WalletTransaction: Comparable {
  static func < (lhs: WalletTransaction, rhs: WalletTransaction) -> Bool {
    return lhs.timestamp < rhs.timestamp
  }
}

extension WalletTransaction: Equatable {
  static func == (lhs: WalletTransaction, rhs: WalletTransaction) -> Bool {
    return lhs.direction == rhs.direction && rhs.transaction.id == lhs.transaction.id
  }
}

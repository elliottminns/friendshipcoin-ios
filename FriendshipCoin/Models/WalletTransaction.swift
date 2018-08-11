//
//  WalletTransaction.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 01/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct WalletTransaction: Timestamped {
  
  enum Direction {
    case `in`
    case out
  }
  
  var direction: Direction {
    return amount > 0 ? .in : .out
  }
  
  var id: String {
    return transaction.id
  }
  
  let transaction: FSCTransaction
  
  var timestamp: UInt32 {
    return transaction.timestamp
  }
  
  var amountIn: UInt64 {
    return credits.reduce(0) {
      $0 + $1.amount
    }
  }
  
  var amountOut: UInt64 {
    return debits.reduce(0) {
      $0 + $1.amount
    }
  }
  
  var amount: Int64 {
    return Int64(amountIn) - Int64(amountOut)
  }
  
  var feelessAmount: Int64 {
    let amount = self.amount
    let adjust = direction == .out ? fee : 0
    return amount + adjust
  }
  
  var fee: Int64 {
    return Int64(transaction.inputsAmount) - Int64(transaction.outputsAmount)
  }
  
  var credits: [WalletCredit] = []
  
  var debits: [WalletDebit] = []
  
  var isPending: Bool = false
  
  var formattedAmount: String {
    return String(format: "%0.8f", Double(self.amount) * 1e-8)
  }

  var time: Date {
    return Date(timeIntervalSince1970: TimeInterval(timestamp))
  }
  
  init(credit: WalletCredit) {
    self.init(transaction: credit.transaction)
    self.credits.append(credit)
  }
  
  init(debit: WalletDebit) {
    self.init(transaction: debit.transaction)
    self.debits.append(debit)
  }
  
  init(transaction: FSCTransaction) {
    TransactionManager.shared.add(transaction: transaction)
    self.transaction = transaction
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

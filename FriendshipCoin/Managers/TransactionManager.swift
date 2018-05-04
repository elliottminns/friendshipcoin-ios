//
//  TransactionManager.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 01/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

class TransactionManager {
  
  static let shared: TransactionManager = TransactionManager()
  
  fileprivate(set) var transactions: [String: FSCTransaction]
  
  fileprivate init() {
    self.transactions = [:]
  }
  
  func add(transaction: FSCTransaction) {
    self.transactions[transaction.id] = transaction
  }
}

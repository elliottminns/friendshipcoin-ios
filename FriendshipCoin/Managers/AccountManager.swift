//
//  AccountManager.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

class AccountManager {
  static let shared = AccountManager()
  
  var accounts: [Account]
  
  var addresses: [Account: [Address]]
  
  var balances: [String: Balance]
  
  var transactions: [String: [Transaction]]
  
  var details: [String: AddressDetails] = [:]
  
  private init() {
    self.accounts = []
    addresses = [:]
    balances = [:]
    transactions = [:]
    
    let accounts = self.getAccounts()
    self.accounts = accounts

  }
  
  func addAccount(for key: String, index: Int, callback: @escaping (Account) -> Void) {
    let account = Account(publicKey: key, index: index)
    self.accounts.append(account)
    callback(account)
  }
  
  func getAccounts() -> [Account] {
    if self.accounts.count > 0 { return self.accounts }
    guard let key = try? KeyManager.shared.getPublicBase58(account: 0) else {
      return []
    }
    let account = Account(publicKey: key, index: 0)
    accounts.append(account)
    return accounts
  }
}

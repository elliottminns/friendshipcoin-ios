//
//  WalletStore.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

class WalletStore {
  let db: Store
  
  let queue: DispatchQueue
  
  struct Key {
    static func addressCount(account: Account) -> String {
      return "\(account.index):count"
    }
    static func creditCount(address: String) -> String {
      return "\(address):credit:count"
    }
    
    static func debitCount(address: String) -> String {
      return "\(address):debit:count"
    }
    
    static func creditIndex(address: String, index: Int) -> String {
      return "\(address):credit:\(index)"
    }
    
    static func debitIndex(address: String, index: Int) -> String {
      return "\(address):debit:\(index)"
    }
    
    static let accountCount: String = "accountcount"
    static let bestBlock: String = "bestBlock"
  }
  
  init() {
    self.db = Store(dbName: "wallet.dat")
    self.queue = DispatchQueue(label: "friendshipcoin.wallet.store")
  }
  
  func addressCount(account: Account) -> Int {
    return queue.sync { return Int(db.get(Key.addressCount(account: account))) ?? 0 }
  }
  
  func save(wallet: Wallet) {
    _ = queue.sync {
      self.db.put(Key.bestBlock, value: wallet.lastBlockScanned.hexEncodedString())
      
      // Each account
      wallet.accounts.forEach { account in
        
        // Each address for account
        wallet.accountAddresses[account]?.enumerated().forEach { item in
          let address = item.element
          self.db.put("\(account.index):\(item.offset)", value: address)
          
          // Credit Count
          let count = wallet.credits[address]?.count ?? 0
          self.db.put(Key.creditCount(address: address), value: "\(count)")
          self.db.put(Key.debitCount(address: address), value: "\(count)")
          
          let credits = wallet.credits[address] ?? []
          
          credits.enumerated().forEach { cItem in
            let credit = cItem.element
            let cIndex = cItem.offset
            self.db.put(Key.creditIndex(address: address, index: cIndex),
                        value: credit.encode().base64EncodedString())
          }
          
          let debits = wallet.debits[address] ?? []
          
          debits.enumerated().forEach { dItem in
            let debit = dItem.element
            let dIndex = dItem.offset
            self.db.put(Key.debitIndex(address: address, index: dIndex),
                        value: debit.encode().base64EncodedString())
          }
        }
        
        // Address Count
        let count = wallet.accountAddresses[account]?.count ?? 0
        self.db.put(Key.addressCount(account: account), value: "\(count)")
      }
      
      self.db.put(Key.accountCount, value: "\(wallet.accounts.count)")
    }
  }
  
  @discardableResult func load(wallet: Wallet) -> Wallet {
    wallet.lastBlockScanned = queue.sync {
      let data = self.db.get(Key.bestBlock)
      guard let hex = data.hexadecimal() else { return Data(count: 32) }
      return hex
    }
    
    let accountCount = queue.sync {
      Int(self.db.get(Key.accountCount)) ?? 0
    }
    
    wallet.loadAccounts(accountCount)
    
    wallet.accounts.forEach { account in
      let addressCount: Int = queue.sync {
        Int(self.db.get(Key.addressCount(account: account))) ?? 0
      }
      
      wallet.accountAddresses[account] = queue.sync {
        (0 ..< addressCount).compactMap { index in
          let address = self.db.get("\(account.index):\(index)")
          guard !address.isEmpty else { return nil }
          
          // load the credits
          let creditCount: Int = Int(self.db.get(Key.creditCount(address: address))) ?? 0
          let debitCount: Int = Int(self.db.get(Key.debitCount(address: address))) ?? 0
          
          wallet.credits[address] = Set<WalletCredit>((0 ..< creditCount).compactMap { cIndex -> WalletCredit? in
            let creditDataStr = self.db.get(Key.creditIndex(address: address, index: cIndex))
            guard let creditData = Data(base64Encoded: creditDataStr) else { return nil }
            
            return WalletCredit.decode(data: creditData)
          })
          
          wallet.debits[address] = Set<WalletDebit>((0 ..< debitCount).compactMap { dIndex -> WalletDebit? in
            let debitDataStr = self.db.get(Key.debitIndex(address: address, index: dIndex))
            guard let debitData = Data(base64Encoded: debitDataStr) else { return nil }
            
            return WalletDebit.decode(data: debitData)
          })
          
          return address
        }
      }
    }
    
    var needsSave = false
    // Ensure that there are at least 250 addresses for each account.
    
    DispatchQueue.global().async {
      let minAddresses = 250
      wallet.accounts.forEach { account in
        let count = (wallet.accountAddresses[account] ?? []).count
        if count < minAddresses {
          let delta = minAddresses - count
          do {
            try wallet.load(addresses: delta, for: account) {}
            needsSave = true
          } catch _ {}
        }
      }
      
      if needsSave { self.save(wallet: wallet) }
    }

    return wallet
  }
}

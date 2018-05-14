//
//  AddressManager.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

typealias AddressManager = AccountManager

extension AccountManager {
  
  func load(addresses number: Int, for account: Account, callback: @escaping () -> Void) throws {
    let count = (self.addresses[account] ?? []).count
    
    let node = try HDNode(base58: account.publicKey,
                          network: NetworkType.friendshipcoin)
    
    let range = count ..< number
    let addresses = range.compactMap { (index) -> Address? in
      guard let value = try? node.derive(0).derive(index).address else {
        return nil
      }
      return Address(address: value, account: account, index: index)
    }
    
    let pre = self.addresses[account] ?? []
    self.addresses[account] = pre + addresses
    
    let service = AddressService(addresses: addresses)
    service.read { (result) in
      if case let .success(details) = result {
        details.forEach {
          self.details[$0.address] = $0
        }
        let balances = details.map { $0.balance }
        balances.forEach { self.balances[$0.address] = $0 }
        details.forEach {
          self.load(transactions: $0.txids, for: $0.address)
        }
      }
      callback()
    }
  }
  
  func balance(for account: Account) -> String {

    let addresses = self.addresses[account] ?? []
    let balances = addresses.compactMap {
      return self.balances[$0.address]
    }
    
    return balances.reduce("0.00", { (result, balance) -> String in
      let current = Double(result) ?? 0
      let next = Double(balance.current) ?? 0
      let total = current + next
      return "\(total)"
    })
  }
  
  func load(transactions txids: [String], for address: String) {
    var txs: [Transaction] = []
    
    let group = DispatchGroup()
    group.enter()
    
    txids.forEach {
      group.enter()
      let req = TransactionRequest(address: address, txid: $0)
      req.perform { result in
        if case let .success(tx) = result {
          txs.append(tx)
        }
        group.leave()
      }
    }
    
    group.notify(queue: DispatchQueue.main) {
      let sorted = txs.sorted(by: { (lhs, rhs) -> Bool in
        return lhs.time.compare(rhs.time) == ComparisonResult.orderedDescending
      })
      self.transactions[address] = sorted
    }
    group.leave()
    
  }
  
  func unusedAddress(for account: Account, callback: @escaping (Address) -> Void) {
    let addresses = self.addresses[account] ?? []
    
    
    if let unused = (addresses.filter {
      return (self.transactions[$0.address] ?? []).count == 0
    }.first) {
      return callback(unused)
    } else {
      try! self.load(addresses: 50, for: account, callback: {
        return self.unusedAddress(for: account, callback: callback)
      })
    }
  }
  
  func transactions(for account: Account) -> [AccountTransaction] {
    let total = addresses[account]?.flatMap { (address) -> [AccountTransaction] in
      let txs = transactions(for: address)
      return txs.map { tx -> AccountTransaction in
        
        let amount = (tx.outputs.filter {
          $0.address == address.id
        }.first?.amount) ?? "0.00"
        
        let direction = self.details[address.id]?.direction(for: tx.id) ?? .out
        return AccountTransaction(amount: amount, direction: direction,
                                  transaction: tx, account: account,
                                  address: address)
      }
    }
    
    return total?.sorted() ?? []
  }
  
  func transactions(for address: Address) -> [Transaction] {
    let txs = self.transactions[address.id] ?? []
    return txs
  }
}

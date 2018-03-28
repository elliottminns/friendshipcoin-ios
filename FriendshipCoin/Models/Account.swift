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
  
  /*
  func getCurrentAddress() throws -> String {
    let unusued = addresses.filter {
      $0.transactions.count == 0
    }
    
    if (unusued.count < 5) {
      self.loadAddresses(100) {}
    }
    
    if let address = unusued.first?.address {
      return address
    } else {
      return try! newReceivingAddress()
    }
  }
  func loadAddresses(_ amount: Int, callback: @escaping () -> Void) {
    let start = self.addresses.count
    let end = start + amount
    let range = start ..< end
    let addresses = range.flatMap { (idx) -> String? in
      guard let node = node else { return nil }
      return try? node.derive(0).derive(idx).address
    }
    
    AddressService(addresses: addresses).read { (result) in
      if case let .success(addy) = result {
        let hash = addy.reduce([String: Address]()) { (set, address) -> [String: Address] in
          var set = set
          set[address.address] = address
          return set
        }
        let ordered = addresses.map {
        }
        self.addresses.append(contentsOf: addy)
      }
      callback()
      self.loading = false
    }
  }

  func newReceivingAddress() throws -> String {
    guard let node = node else { return "" }
    let next = addresses.count
    let value = try node.derive(0).derive(next).address
    
    return value
  }
  
  func waitForLoading(_ callback: @escaping () -> Void) {
    guard loading else { return callback() }
    loaders.append(callback)
  }
}
 */

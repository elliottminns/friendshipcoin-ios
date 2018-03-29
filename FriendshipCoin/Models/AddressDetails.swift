//
//  AddressMeta.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 28/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct AddressDetails {
  let balance: Balance
  
  let txs: [AddressTransaction]
  
  let address: String
  

}

extension AddressDetails {
  var txids: [String] {
    return txs.map { $0.txid }
  }
  
  func direction(for txid: String) -> TransactionDirection {
    return txs.filter { $0.txid == txid }.first?.direction ?? .out
  }
}

extension AddressDetails: JSONConstructable {
  init?(json data: JSON) {
    if let error = data["error"].string,
      let address = data["hash"].string,
      error == "address not found." {
      
      self.address = address
      self.balance = Balance(address: address,
                             sent: "0.00",
                             received: "0.00",
                             current: "0.00")
      self.txs = []
      
      return
    }
    
    guard let address = data["address"].string else { return nil }
    
    let current = data["balance"].string ?? "0.00"
    let sent = data["sent"].string ?? "0.00"
    let received = data["received"].string ?? "0.00"
    
    self.balance = Balance(address: address, sent: sent, received: received, current: current)
    
    self.address = address
    
    let array = data["last_txs"].array ?? []
    self.txs = AddressTransaction.create(json: array)
  }

}


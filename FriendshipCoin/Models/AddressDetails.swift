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
  
  let txids: [String]
  
  let address: String
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
      self.txids = []
      
      return
    }
    
    guard let address = data["address"].string else { return nil }
    
    let current = data["balance"].string ?? "0.00"
    let sent = data["sent"].string ?? "0.00"
    let received = data["received"].string ?? "0.00"
    
    self.balance = Balance(address: address, sent: sent, received: received, current: current)
    
    self.address = address
    
    let array = data["last_txs"].array ?? []
    self.txids = array.flatMap { (obj: JSON) -> String? in
      return obj["addresses"].string
    }
  }

}


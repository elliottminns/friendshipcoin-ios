//
//  AddressTransaction.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 29/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct AddressTransaction {
  let direction: TransactionDirection
  
  let txid: String
}

extension AddressTransaction: JSONConstructable {
  init?(json data: JSON) {
    guard let txid = data["addresses"].string,
      let type = data["type"].string else {
        return nil
    }
    
    self.direction = type == "vin" ? .in : .out
    self.txid = txid
  }
}

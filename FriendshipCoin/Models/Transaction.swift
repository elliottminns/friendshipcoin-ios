//
//  Transactions.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

enum TransactionDirection {
  case `in`
  case out
}

struct Transaction {
  let id: String
  
  let time: Date
  
  let outputs: [Output]
  
  let inputs: [Input]
}

extension Transaction: Comparable {
  static func <(lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.time < rhs.time
  }
  
  static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Transaction: JSONConstructable {
  init?(json data: JSON) {
    guard let txid = data["txid"].string,
      let unixTime = data["time"].int,
      let inputsArray = data["vin"].array,
      let outputsArray = data["vout"].array else {
        return nil
    }
    
    let inputs = Input.create(json: inputsArray)
    let outputs = Output.create(json: outputsArray)
    
    let time = Date(timeIntervalSince1970: TimeInterval(unixTime))
    
    self.id = txid
    self.time = time
    self.inputs = inputs
    self.outputs = outputs
  }
}

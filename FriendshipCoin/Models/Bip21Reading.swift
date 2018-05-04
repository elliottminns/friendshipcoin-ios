//
//  Bip21Reader.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 30/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct Bip21URI {
  
  let address: String
  
  var amount: String? {
    if let amount = keyValues["amount"], let _ = Double(amount) {
      return amount
    } else {
      return nil
    }
  }
  
  let keyValues: [String: String]
  
  let uri: String
  
  init?(uri: String, network: Network = NetworkType.friendshipcoin) {
    self.uri = uri
    let comps = uri.components(separatedBy: "?")
    
    guard let addressComp = comps.first,
      let address = addressComp.components(separatedBy: ":").last else {
        return nil
    }
    
    self.address = address
    
    if comps.last != comps.first {
      let params = comps.last?.components(separatedBy: "&") ?? []
      let keyValues = params.reduce([:], { (data, string) -> [String: String] in
        var data = data
        let keyValue = string.components(separatedBy: "=")
        guard let first = keyValue.first, let last = keyValue.last,
          first != last else { return data }
        data[first] = last
        return data
      })
      
      self.keyValues = keyValues
    } else {
      self.keyValues = [:]
    }
  }
}

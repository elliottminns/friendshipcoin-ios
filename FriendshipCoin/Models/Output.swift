//
//  Outputs.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 28/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct Output {
  let address: String
  
  let amount: String
}

extension Output: JSONConstructable {
  init?(json data: JSON) {
    guard let amount = data["value"].double,
      let addresses = data["scriptPubKey"]["addresses"].array,
      let address = addresses.first?.string else {
        return nil
    }
    
    self.address = address
    self.amount = "\(amount)"
  }
}

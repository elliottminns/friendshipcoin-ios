//
//  FSCTransactionInput.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct FSCTransactionInput: TransactionInput {
  
  var id: String {
    return Data(hash.reversed()).hexEncodedString()
  }
  
  let hash: Data
  
  let index: UInt32
  
  let script: Data
  
  let sequence: UInt32
}

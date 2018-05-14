//
//  FSCBlock.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct FSCBlock: Block {
  
  let hash: Data
  
  let version: Int32

  let previousHash: Data
  
  let merkleRoot: Data
  
  let timestamp: UInt32
  
  let bits: UInt32
  
  let nonce: UInt32
  
  let transactions: [FSCTransaction]
  
  let data: Data
  
  init(data: Data) throws {
    let hash = NeoScrypt().hash(data: data)
    try self.init(data: data, hash: hash)
  }
  
  init(data: Data, hash: Data) throws {
    self.data = data
    self.hash = hash
    
    let reader = DataReader(data: data)
    version = try reader.read(endian: .little)
    previousHash = try reader.read(bytes: 32)
    merkleRoot = try reader.read(bytes: 32)
    timestamp = try reader.read(endian: .little)
    bits = try reader.read(endian: .little)
    nonce = try reader.read(endian: .little)
    
    let transactionCount = reader.readVariableInt()
    
    transactions = try (0 ..< transactionCount).map { index in
      return try FSCTransaction(reader: reader, blockHash: hash)
    }
  }
}

//
//  FSCTransaction.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 26/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct FSCTransaction: CoinKit.Transaction {
  
  var hash: Data {
    return self.data.sha256.sha256
  }

  typealias Input = FSCTransactionInput
  
  let blockHash: Data
  
  let version: UInt32
  
  let inputs: [FSCTransactionInput]
  
  let outputs: [TransactionOutput]
  
  let locktime: UInt32
  
  let timestamp: UInt32
  
  fileprivate var _data: Data?
  
  fileprivate var _id: String?
  
  var outputsAmount: UInt64 {
    return outputs.reduce(0) { $0 + $1.amount }
  }
  
  var inputsAmount: UInt64 {
    return inputs.reduce(0) { (result, input) in
      let id = input.id
      guard let tx = TransactionManager.shared.transactions[id] else { return 0 }
      let txo = tx.outputs[Int(input.index)]
      return result + txo.amount
    }
  }
  
  var inputAddresses: Set<String> {
    let addresses = inputs.compactMap { input in
      return input.address(network: NetworkType.friendshipcoin)?.address
    }
    return Set<String>(addresses)
  }
  
  var outputAddresses: Set<String> {
    let addresses = outputs.compactMap { output in
      return output.address(network: NetworkType.friendshipcoin)?.address
    }
    return Set<String>(addresses)
  }
  
  var id: String {
    if let id = self._id { return id }
    return Data(self.data.sha256.sha256.reversed()).hexEncodedString()
  }
  
  var data: Data {
    if let data = _data { return data }
    return self.toData()
  }

  init(version: UInt32, timestamp: UInt32, locktime: UInt32, inputs: [FSCTransactionInput], outputs: [TransactionOutput]) {
    self.version = version
    self.locktime = locktime
    self.inputs = inputs
    self.outputs = outputs
    self._data = nil
    self._id = nil
    self.blockHash = Data()
    self.timestamp = timestamp
  }
  
  init(data: Data) throws {
    let reader = DataReader(data: data)
    try self.init(reader: reader, blockHash: Data())
  }
  
  init(reader: DataReader, blockHash: Data) throws {
    
    let start = reader.position
    
    version = try reader.read(endian: .little)
    timestamp = try reader.read(endian: .little)
    
    let vinLength = reader.readVariableInt()
    let range = (0 ..< vinLength)
    
    self.inputs = try range.map { (index: UInt) -> FSCTransactionInput in
      let hash = try reader.read(bytes: 32)
      let idx: UInt32 = try reader.read(endian: .little)
      let script = try reader.readVariableBytes()
      let sequence: UInt32 = try reader.read(endian: .little)
      return FSCTransactionInput(hash: hash, index: idx, script: script, sequence: sequence)
    }
    
    let vout = reader.readVariableInt()
    
    let voutRange = (0 ..< vout)
    self.outputs = voutRange.map { (index: UInt) -> TransactionOutput in
      do {
        let value: UInt64 = try reader.read(endian: .little)
        let script = try reader.readVariableBytes()
        return TransactionOutput(amount: value, script: script)
      } catch _ {
        return TransactionOutput(amount: 0)
      }
    }
    
    locktime = try reader.read(endian: .little)
    
    let end = reader.position
    let data = Data(reader.data[reader.data.startIndex + Int(start) ..< reader.data.startIndex + Int(end)])
    self._data = data
    self._id = Data(data.sha256.sha256.reversed()).hexEncodedString()
    self.blockHash = blockHash
  }
  
  public func toData() -> Data {
    var data = Data()
    data.append(bytesFrom: version, endian: .little)
    data.append(bytesFrom: timestamp, endian: .little)
    data.append(variable: inputs.count, endian: .little)
    
    inputs.forEach { input in
      data.append(input.hash)
      data.append(bytesFrom: input.index, endian: .little)
      data.append(variable: input.script, endian: .little)
      data.append(bytesFrom: input.sequence, endian: .little)
    }
    
    data.append(variable: outputs.count, endian: .little)
    
    outputs.forEach { output in
      data.append(bytesFrom: output.amount, endian: .little)
      data.append(variable: output.script, endian: .little)
    }
    
    data.append(bytesFrom: locktime, endian: .little)
    
    return data
  }
  
  func encoded() -> Data {
    return self.blockHash + self.data
  }
  
  static func decode(reader: DataReader) throws -> FSCTransaction {
    let blockhash = try reader.read(bytes: 32)
    return try FSCTransaction(reader: reader, blockHash: blockhash)
  }
  
  static func decode(data: Data) throws -> FSCTransaction {
    let reader = DataReader(data: data)
    return try decode(reader: reader)
  }
}

extension FSCTransaction: Hashable {
  var hashValue: Int { return id.hashValue }
  
  static func ==(lhs: FSCTransaction, rhs: FSCTransaction) -> Bool {
    return lhs.id == rhs.id
  }
}

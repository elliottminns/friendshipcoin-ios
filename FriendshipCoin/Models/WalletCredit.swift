//
//  WalletInput.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct WalletCredit: Hashable {
  
  let address: String
  
  let outputIndex: Int
  
  let transaction: FSCTransaction
  
  var hashValue: Int {
    return "\(transaction.id)-\(outputIndex)".hashValue
  }
  
  var output: TransactionOutput {
    return transaction.outputs[outputIndex]
  }
  
  var amount: UInt64 {
    return output.amount
  }
  
  init?(transaction: FSCTransaction, outputIndex: Int) {
    guard let address = transaction.outputs[outputIndex]
      .address(network: NetworkType.friendshipcoin)?.address else { return nil }
    self.init(transaction: transaction, outputIndex: outputIndex, address: address)
  }
  
  init(transaction: FSCTransaction, outputIndex: Int, address: String) {
    self.transaction = transaction
    self.outputIndex = outputIndex
    self.address = address
  }
  
  func encode() -> Data {
    var data = Data()
    data.append(transaction.encoded())
    data.append(variable: outputIndex, endian: .little)
    return data
  }
  
  static func decode(data: Data) -> WalletCredit? {
    let reader = DataReader(data: data)
    guard let transaction = try? FSCTransaction.decode(reader: reader) else { return nil }
    let outputIndex = Int(reader.readVariableInt())
    let credit = WalletCredit(transaction: transaction, outputIndex: outputIndex)
    return credit
  }
}

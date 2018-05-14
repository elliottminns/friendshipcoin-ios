//
//  WalletOutput.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct WalletDebit: Hashable {
  
  let transaction: FSCTransaction
  
  let inputIndex: Int
  
  let address: String
  
  var amount: UInt64 {
    return transaction.inputsAmount
  }
  
  var hashValue: Int {
    return "\(transaction.id)-\(inputIndex)".hashValue
  }
  
  var input: FSCTransactionInput {
    return transaction.inputs[inputIndex]
  }
  
  init?(transaction: FSCTransaction, inputIndex: Int) {
    guard let address = transaction.inputs[inputIndex].address(network: NetworkType.friendshipcoin) else { return nil }
    self.init(transaction: transaction, inputIndex: inputIndex, address: address.address)
  }
  
  init(transaction: FSCTransaction, inputIndex: Int, address: String) {
    self.transaction = transaction
    self.inputIndex = inputIndex
    self.address = address
  }
  
  func encode() -> Data {
    var data = Data()
    data.append(transaction.encoded())
    data.append(variable: inputIndex, endian: .little)
    return data
  }
  
  static func decode(data: Data) -> WalletDebit? {
    let reader = DataReader(data: data)
    guard let transaction = try? FSCTransaction.decode(reader: reader) else { return nil }
    let inputIndex = Int(reader.readVariableInt())
    let debit = WalletDebit(transaction: transaction, inputIndex: inputIndex)
    return debit
  }
}

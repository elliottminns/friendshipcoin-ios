//
//  TransactionRequest.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 28/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct TransactionRequest: ExplorerRequest {
  
  typealias ParsedType = Transaction
  
  let path: String// = "/api/getrawtransaction"
  
  //let parameters: [String : Any]
  
  init(address: String, txid: String) {
    /*
    parameters = [
      "decrypt": "1",
      "txid": txid
    ]*/
    
    path = "/api/getrawtransaction?txid=\(txid)&decrypt=1"
  }
}

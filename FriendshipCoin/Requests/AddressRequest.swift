//
//  AddressRequest.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct AddressRequest: ExplorerRequest {
  let path: String
  
  typealias ParsedType = AddressDetails
  
  init(address: Address) {
    path = "/ext/getaddress/\(address.address)"
  }
  
  
}

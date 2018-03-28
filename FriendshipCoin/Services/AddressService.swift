//
//  AddressService.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

struct AddressService: Readable {

  let addresses: [Address]
  
  typealias ResultType = AddressDetails

  init(addresses: [Address]) {
    self.addresses = addresses
  }
  
  func read(callback: @escaping (Result<[AddressDetails]>) -> Void) {
    let group = DispatchGroup()
    group.enter()
    
    var results: [AddressDetails] = []
    
    self.addresses.forEach {
      group.enter()
      let request = AddressRequest(address: $0)
      request.perform(callback: { (res) in
        if case let .success(address) = res {
          results.append(address)
        }
        group.leave()
      })
    }
    
    group.notify(queue: DispatchQueue.main) {
      callback(.success(results))
    }
    group.leave()
    
  }
}


//
//  ChainElement.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 06/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

protocol ChainElement {
  var hash: Data  { get }
  
  var previousHash: Data { get }
}

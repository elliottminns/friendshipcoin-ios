//
//  ExplorerRequest.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 26/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

protocol ExplorerRequest: JSONBuildableRequest, SendableRequest, JSONResultParsing {
  
}

extension ExplorerRequest {
  var baseUrl: URL? { return URL(string: "https://explore.friendshipcoin.com/") }
}

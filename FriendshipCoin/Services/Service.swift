//
//  Service.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation

protocol Service {
  associatedtype ResultType
}

protocol Readable: Service {
  func read(callback: @escaping (Result<[ResultType]>) -> Void)
}

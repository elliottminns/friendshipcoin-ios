//
//  Result.swift
//  CoinBundle
//
//  Created by Elliott Minns on 17/01/2017.
//  Copyright © 2017 Elliott Minns. All rights reserved.
//

import Foundation

public enum Result<T> {
  case success(T)
  case failure(Error)
}

extension Result {
  func map<U>(f: (T) -> U) -> Result<U> {
    switch self {
    case let .success(value):
      return Result<U>.success(f(value))
    case let .failure(error):
      return Result<U>.failure(error)
    }
  }
  
  func fold(_ f: (T) -> Void, _ g: (Error) -> Void) -> Void {
    switch self {
    case let .success(value): f(value)
    case let .failure(error): g(error)
    }
  }
}

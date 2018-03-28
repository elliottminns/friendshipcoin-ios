//
//  Client.swift
//  CoinBundle
//
//  Created by Elliott Minns on 17/01/2017.
//  Copyright © 2017 Elliott Minns. All rights reserved.
//

import Foundation

typealias ClientCallback =  (Data?, URLResponse?, Error?) -> ()

protocol RequestClient {
  func perform(request: URLRequest, callback: @escaping ClientCallback)
}

class SessionClient: RequestClient {
  private let session: URLSession
  
  init() {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 15;
    config.timeoutIntervalForResource = 30;
    session = URLSession(configuration: config)
  }
  
  func perform(request: URLRequest, callback: @escaping ClientCallback) {
    let task = session.dataTask(with: request) { data, res, err in
     
      DispatchQueue.main.async {
        callback(data, res, err)
      }
    }
    
    task.resume()
    
  }
}

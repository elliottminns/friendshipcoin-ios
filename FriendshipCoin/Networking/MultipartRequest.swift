//
//  MultipartRequest.swift
//  CoinBundle
//
//  Created by Elliott Minns on 18/01/2017.
//  Copyright © 2017 Elliott Minns. All rights reserved.
//

import Foundation

fileprivate extension Data {
  mutating func append(_ string: String) {
    guard let sData = string.data(using: .utf8) else { return }
    self.append(sData)
  }
}

protocol MultipartRequest: BuildableRequest {
  var files: [String: [Data]] { get }
  
}

extension MultipartRequest {
  
  var method: RequestMethod { return .post }
  
  func buildRequest() -> URLRequest? {
    
    let boundary = "Boundary-\(NSUUID().uuidString)"
    
    guard let url = URL(string: path, relativeTo: baseUrl),
      let data = buildBody(withBoundary: boundary),
      method == RequestMethod.post || method == RequestMethod.put else {
          return nil
    }
    
    var urlRequest = URLRequest(url: url)
    
    urlRequest.allHTTPHeaderFields = {
      var h = self.headers
      h["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
      h["Content-Length"] = String(data.count)
      return h
    }()
    
    urlRequest.httpMethod = method.rawValue
    urlRequest.httpBody = data
    
    return urlRequest
  }
  
  func buildBody(withBoundary boundary: String) -> Data? {
    
    var body = Data()
    
    for (key, value) in parameters {
      body.append("--\(boundary)\r\n")
      body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
      body.append("\(value)\r\n")
    }
    
    for (key, value) in files {
      for i in 0 ..< value.count {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)_\(i).png\"\r\n")
        body.append("Content-Type: image/png\r\n\r\n")
        body.append(value[i])
        body.append("\r\n")
      }
    }
    body.append("--\(boundary)--\r\n")
    
    return body
  }
}

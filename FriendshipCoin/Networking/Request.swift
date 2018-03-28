//
//  Request.swift
//  CoinBundle
//
//  Created by Elliott Minns on 17/01/2017.
//  Copyright © 2017 Elliott Minns. All rights reserved.
//

import Foundation

enum RequestMethod: String {
  case get = "GET"
  case put = "PUT"
  case post = "POST"
  case delete = "DELETE"
}

public struct RequestError: Error {
  let message: String
}

protocol Request {
  var path: String { get }
  var baseUrl: URL? { get }
  var method: RequestMethod { get }
  var parameters: [String: Any] { get }
  var headers: [String: String] { get }
}

extension Request {
  var method: RequestMethod { return .get }
  var parameters: [String: Any] { return [:] }
  var headers: [String: String] { return [:] }
}

protocol BuildableRequest: Request {
  func buildRequest() -> URLRequest?
}

protocol JSONBuildableRequest: BuildableRequest {}
extension JSONBuildableRequest {
  func buildRequest() -> URLRequest? {
    guard let url = URL(string: path, relativeTo: baseUrl),
      let data = try? JSONSerialization.data(withJSONObject: parameters,
                                         options: []) else {
        return nil
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.allHTTPHeaderFields = {
      var headers = self.headers
      headers["Content-Type"] = "application/json"
      return headers
    }()
    
    urlRequest.httpMethod = method.rawValue
    
    if method == .get && parameters.count > 0 {
      if let comps = createComponents(for: url) {
        urlRequest.url = comps.url
      }
    } else if parameters.count > 0 {
      urlRequest.httpBody = data
    }
    
    return urlRequest
  }
  
  func createComponents(for url: URL) -> URLComponents? {
    var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)
    let queryItems: [URLQueryItem] = parameters.map {
      let set = CharacterSet.urlQueryAllowed
      let value = "\($0.1)".addingPercentEncoding(withAllowedCharacters: set)
      return URLQueryItem(name: $0.0, value: value)
    }
    comps?.queryItems = queryItems
    return comps
  }
}

protocol SendableRequest: BuildableRequest, ResultParsing {}

extension SendableRequest {
  
  func handleResult(data: Data?, response: URLResponse?, error: Error?,
                    callback: @escaping (Result<ParsedType>) -> Void) {
    var err: Error?
    
    var obj: ParsedType?
    
    defer {
      
      let result: Result<ParsedType>
      
      if let err = err {
        result = Result.failure(err)
      } else if let obj = obj {
        result = Result.success(obj)
      } else {
        let error = RequestError(message: "Something went wrong")
        result = Result.failure(error)
      }
      
      callback(result)
    }
    
    
    guard let data = data else {
      err = RequestError(message: "No data in response")
      return
    }
    
    guard let parsed = self.parse(data: data) else {
      err = RequestError(message: "Could not parse result")
      return
    }
    
    obj = parsed
  }
  
  func perform(callback: @escaping (Result<ParsedType>) -> ()) {
    
    sendRequest(with: Requester.client, callback: callback)
  }
  
  func sendRequest(with client: RequestClient,
                   callback: @escaping (Result<ParsedType>) -> ()) {
    
    guard let request = buildRequest() else {
      let error = RequestError(message: "Could not build request")
      let result = Result<ParsedType>.failure(error)
      return callback(result)
    }
    
    client.perform(request: request) { (data, response, error) in
      self.handleResult(data: data, response: response, error: error, callback: callback)
    }
    
  }
}

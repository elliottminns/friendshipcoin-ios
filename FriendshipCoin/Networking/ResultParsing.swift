//
//  ResultParsing.swift
//  CoinBundle
//
//  Created by Elliott Minns on 17/01/2017.
//  Copyright © 2017 Elliott Minns. All rights reserved.
//

import Foundation
import SwiftyJSON

class JSONParser {
  
  static func parse(data: Data) -> [String: AnyObject]? {
    do {
      let serial = try JSONSerialization.jsonObject(with: data, options: [])
      return serial as? [String: AnyObject]
    } catch {
      print(error)
    }
    
    return nil
  }
}

protocol ResultParsing {
  
  associatedtype ParsedType
  
  func parse(data: Data) -> ParsedType?
  
  func parse(error data: Data) -> Error?
}

protocol JSONResultParsing: ResultParsing {
  func parse(json data: JSON) -> ParsedType?
}

extension JSONResultParsing {
  func parse(error data: Data) -> Error? {
    return RequestError(message: "Something went wrong")
  }
  func parse(data: Data) -> ParsedType? {
    guard let json = try? JSON(data: data) else { return nil }
    return parse(json: json)
  }
}

typealias JSON = SwiftyJSON.JSON

protocol JSONConstructable {
  init?(json data: JSON)
}

extension JSONConstructable {
  static func create(json data: [JSON]) -> [Self] {
    return data.compactMap { item in
      Self.init(json: item)
    }
  }
}

extension JSONResultParsing where ParsedType: JSONConstructable {
  func parse(json: JSON) -> ParsedType? {
    return ParsedType(json: json)
  }
}

extension JSONResultParsing where ParsedType: Sequence, ParsedType.Element: JSONConstructable {
  func parse(json data: JSON) -> ParsedType? {
    guard let array = data.array else { return nil }
    return ParsedType.Element.create(json: array) as? ParsedType
  }
}

//
//  UITextField+Currency.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 30/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

extension UITextField {
  func isAllowedCurrencyEdit(range: NSRange,
                             replacementString string: String) -> Bool {
    let textField = self
    
    if string == "." {
      guard let text = textField.text, !text.contains(".") else {
        return false
      }
      
      guard text.count > 0 else {
        textField.text = "0."
        return false
      }
      
      return true
    }
    
    if range.length > 0 && string == "" {
      guard let text = textField.text else { return false }
      
      if text.first == "0" && range.length >= text.count - 1 {
        textField.text = ""
        return false
      }
    }
    
    if string == "0" && textField.text == "0" {
      return false
    }
    
    guard let text = textField.text else { return true }
    guard text.count < 12 else { return string == "" }
    let splits = text.components(separatedBy: ".")
    guard splits.count == 2, let decimal = splits.last else {
      return true
    }
    
    return decimal.count < 8 || string == ""
  }
}

//
//  UIFont+Style.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 24/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

extension UIFont {
  static func titleFont(with size: CGFloat = 24) -> UIFont {
    return monserrat(with: size, bold: true)
  }
  
  static func monserrat(with size: CGFloat, bold: Bool = false) -> UIFont {
    let name = bold ? "Montserrat-Bold" : "Montserrat"
    return UIFont(name: name, size: size)!
  }
}

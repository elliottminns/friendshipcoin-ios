//
//  UIButton+Style.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 24/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

extension UIButton {
  func fscStyle() {
    self.backgroundColor = UIColor.fscBlue
    self.layer.cornerRadius = 4
    self.titleLabel?.font = UIFont.monserrat(with: 18)
  }
  
  func fscInverted() {
    self.backgroundColor = UIColor.white
    self.setTitleColor(UIColor.fscBlue, for: [])
    self.titleLabel?.font = UIFont.monserrat(with: 18)
  }
}

//
//  Setting.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 19/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

class SettingDisplayTableViewCell: UITableViewCell, SettingCell {
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    let style = UITableViewCellStyle.value1
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    self.textLabel?.font = UIFont.monserrat(with: 18)
    self.detailTextLabel?.font = UIFont.monserrat(with: 16)
    
  }
  
}

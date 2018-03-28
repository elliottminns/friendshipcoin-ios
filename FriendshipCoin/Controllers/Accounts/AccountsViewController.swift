//
//  AccountsViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
    self.title = "Accounts"
    self.tabBarItem.image = #imageLiteral(resourceName: "accounts")
    self.render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
  }
}


//
//  SendViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 28/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {
  
  let addressField = UITextField()
  
  let amountField = UITextField()
  
  let confirmButton = UIButton()
  
  init(account: Account) {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

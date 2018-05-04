//
//  SendAddressViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 30/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

enum SendAddressViewControllerError: Error {
  case incorrectParams
  case notEnoughBalance
}

class SendAddressViewController: UIViewController {
  
  let toLabel = UILabel()
  
  let toField = UITextField()
  
  let feeLabel = UILabel()
  
  let account: Account
  
  let amount: String
  
  init(account: Account, amount: String) throws {
    guard let balance = Double(account.totalBalance),
      let amountD = Double(amount) else {
        throw SendAddressViewControllerError.incorrectParams
    }
    
    guard balance >= amountD else {
      throw SendAddressViewControllerError.notEnoughBalance
    }
    
    self.account = account
    self.amount = amount
    super.init(nibName: nil, bundle: nil)
    self.render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    title = amount
  }
}

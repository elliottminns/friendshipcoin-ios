//
//  BalanceViewControllers.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 24/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import Stevia

class BalanceViewController: UIViewController {
  
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  let balanceLabel: UILabel = UILabel()
  
  let logo: UIImageView = UIImageView()
  
  let stack = UIStackView()
  
  let sendButton = UIButton()
  
  let receiveButton = UIButton()
  
  var account: Account?
  
  init() {
    super.init(nibName: nil, bundle: nil)
    self.title = "Balance"
    self.tabBarItem.image = #imageLiteral(resourceName: "balance")
    self.render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    
    view.sv(activityIndicator, stack)
    
    activityIndicator.centerInContainer()
    activityIndicator.hidesWhenStopped = true
    activityIndicator.startAnimating()
    
    stack.axis = .vertical
    stack.distribution = .equalCentering
    stack.alignment = .center
    stack.centerInContainer()
    stack.left(to: view, view.safeAreaLayoutGuide.leftAnchor, offset: 24)
    stack.right(to: view, view.safeAreaLayoutGuide.rightAnchor, offset: -24)
    stack.spacing = 18
    stack.isHidden = true
    
    stack.addArrangedSubview(logo)
    stack.addArrangedSubview(balanceLabel)
    stack.addArrangedSubview(sendButton)
    stack.addArrangedSubview(receiveButton)
    
    logo.image = #imageLiteral(resourceName: "Logo")
    logo.width(90).height(90)
    
    balanceLabel.font = UIFont.titleFont(with: 24)
    balanceLabel.textAlignment = .center
    
    setup(button: sendButton)
    sendButton.setTitle("Send", for: [])
    
    setup(button: receiveButton)
    receiveButton.addTarget(self, action: #selector(receiveButtonPressed),
                            for: .touchUpInside)
    receiveButton.setTitle("Receive", for: [])
  }
  
  func setup(button: UIButton) {
    button.fscStyle()
    button.width(65%)
    button.height(44)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.account = AccountManager.shared.accounts.first
    guard let account = self.account else { return }
    let manager = AddressManager.shared
    try? manager.load(addresses: 50, for: account) {
      self.balanceLabel.text = manager.balance(for: account)
      self.stack.isHidden = false
      self.activityIndicator.stopAnimating()
    }
  }
  
  @objc
  func receiveButtonPressed() {
    guard let account = account else { return }
    let controller = ReceiveViewController(account: account)
    let navigationController = UINavigationController(rootViewController: controller)
    present(navigationController, animated: true, completion: nil)
  }
}

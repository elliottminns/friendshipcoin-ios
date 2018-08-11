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
  
  let balanceLabel: UILabel = UILabel()
  
  let logo: UIImageView = UIImageView()
  
  let stack = UIStackView()
  
  let sendButton = UIButton()
  
  let receiveButton = UIButton()
  
  let syncingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  let syncingLabel = UILabel()
  
  let syncingDetailLabel = UILabel()
  
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
    
    view.sv(stack, syncingLabel, syncingIndicator, syncingDetailLabel)
    
    stack.axis = .vertical
    stack.distribution = .equalCentering
    stack.alignment = .center
    stack.centerInContainer()
    stack.left(to: view, view.safeAreaLayoutGuide.leftAnchor, offset: 24)
    stack.right(to: view, view.safeAreaLayoutGuide.rightAnchor, offset: -24)
    stack.spacing = 18

    stack.addArrangedSubview(logo)
    stack.addArrangedSubview(balanceLabel)
    stack.addArrangedSubview(sendButton)
    stack.addArrangedSubview(receiveButton)
    
    syncingLabel.text = NetworkManager.shared.syncMessage ?? "Synchronizing with network..."
    syncingLabel.font = UIFont.monserrat(with: 18)
    
    syncingDetailLabel.text = NetworkManager.shared.syncDetailMessage ?? nil
    syncingDetailLabel.font = UIFont.monserrat(with: 18)
    
    syncingIndicator.hidesWhenStopped = true

    syncingLabel.topToSuperview(offset: 12, usingSafeArea: true)
    syncingLabel.centerHorizontally()
    syncingIndicator.rightToLeft(of: syncingLabel, offset: -8)
    syncingIndicator.centerY(to: syncingLabel)
    syncingLabel.textAlignment = .center
    
    syncingDetailLabel.textAlignment = .center
    syncingDetailLabel.left(to: syncingLabel)
    syncingDetailLabel.right(to: syncingLabel)
    syncingDetailLabel.topToBottom(of: syncingLabel, offset: 8)
    
    
    logo.image = #imageLiteral(resourceName: "Logo")
    logo.width(90).height(90)
    
    balanceLabel.font = UIFont.titleFont(with: 24)
    balanceLabel.textAlignment = .center
    balanceLabel.text = "0.0 FSC"
    
    setup(button: sendButton)
    sendButton.addTarget(self, action: #selector(sendButtonPressed),
                         for: .touchUpInside)
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    NotificationCenter.default.addObserver(
      self, selector: #selector(syncingStarted),
      name: NetworkManager.Notifications.isSyncingStarted,
      object: NetworkManager.shared
    )
    NotificationCenter.default.addObserver(
      self, selector: #selector(syncingStopped),
      name: NetworkManager.Notifications.isSyncingStopped,
      object: NetworkManager.shared
    )
    NotificationCenter.default.addObserver(
      self, selector: #selector(onSyncMessage),
      name: NetworkManager.Notifications.syncMessage,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self, selector: #selector(onSyncDetailMessage),
      name: NetworkManager.Notifications.syncDetailMessage,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self, selector: #selector(walletScanned),
      name: Wallet.Notifications.scanningEnded,
      object: nil
    )
    
    updateView()
  }
  
  
  
  func updateView() {
    let wallet = NetworkManager.shared.wallet
    self.account = wallet.accounts.first
    guard let account = self.account else { return }
    
    self.balanceLabel.text = wallet.balance(for: account)
    self.stack.isHidden = false

    if NetworkManager.shared.isSyncing {
      syncingLabel.isHidden = false
      syncingIndicator.isHidden = false
      syncingIndicator.startAnimating()
      syncingLabel.text = NetworkManager.shared.syncMessage ?? "Synchronizing with network..."
      syncingDetailLabel.text = NetworkManager.shared.syncDetailMessage
    } else {
      self.syncingLabel.isHidden = true
      self.syncingDetailLabel.isHidden = true
      self.syncingIndicator.stopAnimating()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let seed = try! KeyManager.shared.pubKeychain.get("m/44'/0'/0'")
    print(seed ?? "" )
  }
  
  @objc
  func receiveButtonPressed() {
    guard let account = account else { return }
    let controller = ReceiveViewController(account: account, wallet: NetworkManager.shared.wallet)
    let nav = UINavigationController(rootViewController: controller)
    present(nav, animated: true, completion: nil)
  }
  
  @objc
  func sendButtonPressed() {
    guard let account = account else { return }
    let controller = SendViewController(account: account, wallet: NetworkManager.shared.wallet)
    let nav = UINavigationController(rootViewController: controller)
    present(nav, animated: true, completion: nil)
  }
  
  @objc
  func syncingStarted() {
    self.syncingLabel.isHidden = false
    self.syncingIndicator.startAnimating()
  }
  
  @objc
  func syncingStopped() {
    NetworkManager.shared.wallet.scanForBalances {
      let account = NetworkManager.shared.wallet.accounts[0]
      self.balanceLabel.text = NetworkManager.shared.wallet.balance(for: account)
      self.syncingLabel.isHidden = true
      self.syncingIndicator.stopAnimating()
    }
  }
  
  @objc
  func walletScanned() {
    let account = NetworkManager.shared.wallet.accounts[0]
    self.balanceLabel.text = NetworkManager.shared.wallet.balance(for: account)
  }
  
  @objc
  func onSyncMessage(notification: Notification) {
    guard let message = notification.userInfo?["message"] as? String else { return }
    self.syncingLabel.text = message
  }
  
  @objc
  func onSyncDetailMessage(notification: Notification) {
    guard let message = notification.userInfo?["message"] as? String else { return }
    self.syncingDetailLabel.text = message
  }
}

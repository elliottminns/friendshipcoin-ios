//
//  RestoreWalletViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import Stevia
import CoinKit

class RestoreWalletViewController: UIViewController {
  
  let scroll = UIScrollView()
  
  let stack = UIStackView()
  
  let label = UILabel()
  
  let wordsTextView = UITextView()
  
  let submitButton = UIButton()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    title = "Restore Wallet"
    /*
    view.sv(scroll)
    scroll.sv(stack)

    scroll.top(to: view, view.safeAreaLayoutGuide.topAnchor)
    scroll.bottom(to: view, view.safeAreaLayoutGuide.bottomAnchor)
    scroll.leftToSuperview()
    scroll.rightToSuperview
     */
    
    view.sv(stack)
    stack.topToSuperview(offset: 12, usingSafeArea: true)
    stack.leftToSuperview(offset: 12)
    stack.rightToSuperview(offset: 12)
    stack.distribution = .equalCentering
    stack.alignment = .center
    stack.axis = .vertical
    stack.spacing = 12
    
    stack.addArrangedSubview(label)
    stack.addArrangedSubview(wordsTextView)
    stack.addArrangedSubview(submitButton)
    
    label.textAlignment = .center
    label.text = "Please enter your 24 recovery words below"
    label.numberOfLines = 0
    label.leftToSuperview()
    label.rightToSuperview()
    label.font = UIFont.titleFont(with: 18)
    
    wordsTextView.font = UIFont.monserrat(with: 18, bold: true)
    wordsTextView.height(120)
    wordsTextView.layer.borderColor = UIColor.fscBlue.cgColor
    wordsTextView.layer.borderWidth = 1
    wordsTextView.layer.cornerRadius = 8
    wordsTextView.leftToSuperview()
    wordsTextView.rightToSuperview()
    wordsTextView.textAlignment = .center
    wordsTextView.autocapitalizationType = .none
    
    submitButton.fscStyle()
    submitButton.height(44)
    submitButton.width(65%)
    submitButton.setTitle("Restore", for: [])
    submitButton.addTarget(self, action: #selector(restoreWallet), for: .touchUpInside)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    wordsTextView.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  @objc
  func restoreWallet() {
    let trimmed = wordsTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    guard trimmed.components(separatedBy: " ").count == 24 else { return }
    let mnemonic = Mnemonic(words: trimmed)
    wordsTextView.resignFirstResponder()
    KeyManager.shared.store(mnemonic: mnemonic)
    let account = try! KeyManager.shared.getPublicBase58(account: 0)
    AccountManager.shared.addAccount(for: account, index: 0) { (account) in
      self.dismiss(animated: true, completion: nil)
    }
  }
  
}

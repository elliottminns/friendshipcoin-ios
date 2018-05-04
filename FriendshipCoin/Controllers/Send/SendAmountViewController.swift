//
//  SendViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 28/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import Stevia
import TinyConstraints

class SendAmountViewController: UIViewController {
  
  let account: Account
  
  let availableLabel = UILabel()
  
  let amountLabel = UILabel()
  
  let nextButton = UIButton()
  
  let keyboardView = NumberPadView()
  
  var amount: String = "" {
    didSet {
      if amount.count > 0 {
        amountLabel.text = "\(amount) FSC"
      } else {
        amountLabel.text = "0 FSC"
      }
    }
  }

  init(account: Account) {
    self.account = account
    super.init(nibName: nil, bundle: nil)
    keyboardView.delegate = self
    self.render()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    title = "Send Payment"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close",
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(close))
    
    view.sv([availableLabel, amountLabel, keyboardView, nextButton])
    
    let margin: CGFloat = 8
    
    availableLabel.centerHorizontally()
    availableLabel.textAlignment = .center
    availableLabel.text = "\(account.totalBalance) FSC Available"
    availableLabel.font = UIFont.monserrat(with: 14, bold: false)
    availableLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
    availableLabel.topToSuperview(offset: margin, usingSafeArea: true)
    availableLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    
    amountLabel.font = UIFont.monserrat(with: 36)
    amountLabel.textColor = UIColor.fscBlue
    amountLabel.text = "0 FSC"
    amountLabel.textAlignment = .center
    amountLabel.centerHorizontally()
    amountLabel.topToBottom(of: availableLabel, offset: margin * 4)
    amountLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    amountLabel.leftToSuperview(offset: 8)
    amountLabel.rightToSuperview(offset: 8)
    amountLabel.minimumScaleFactor = 0.5
    
    nextButton.backgroundColor = UIColor.fscBlue
    nextButton.setTitle("Next", for: [])
    
    nextButton.leftToSuperview(offset: margin)
    nextButton.rightToSuperview(offset: margin)
    nextButton.bottomToSuperview(offset: -margin, usingSafeArea: true)
    nextButton.fscStyle()
    nextButton.height(54.0)
    nextButton.titleLabel?.font = UIFont.titleFont(with: 18)
    
    keyboardView.width(100%)
    keyboardView.height(to: keyboardView, keyboardView.widthAnchor)
    keyboardView.setContentHuggingPriority(.defaultLow, for: UILayoutConstraintAxis.vertical)
    keyboardView.bottomToTop(of: nextButton, offset: -margin)
    
    keyboardView.topToBottom(of: amountLabel, offset: margin, relation: ConstraintRelation.equalOrGreater)
  }
  
  @objc
  func close() {
    self.dismiss(animated: true, completion: nil)
  }
  
  func backspace() {
    guard amount.count > 0 else { return }
    amount.remove(at: amount.index(before: amount.endIndex))
  }
  
  func decimal() {
    guard !amount.contains(".") else { return }
    switch amount.count {
    case 0: amount = "0."
    default: amount.append(".")
    }
  }
  
  func number(_ value: Int) {
    guard amount.count < 9 else { return }
    let splits = amount.components(separatedBy: ".")
    guard splits.count == 2, let decimal = splits.last else {
      amount.append("\(value)")
      return
    }
    
    if decimal.count < 8 {
      amount.append("\(value)")
    }
  }
}

extension SendAmountViewController: NumberPadDelegate {
  func numberPad(view: NumberPadView, didSelectNumber key: NumberPadViewKey) {
    switch key {
    case .backspace: backspace()
    case .number(let value): number(value)
    case .decimal: decimal()
    }
  }
}

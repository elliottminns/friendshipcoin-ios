//
//  TransactionViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 14/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import SwiftMoment
import ToastSwiftFramework

fileprivate extension UIView {
  static func separator(superview: UIView, margin: CGFloat = 24.0) -> UIView {
    let view = UIView()
    superview.addSubview(view)
    view.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
    view.height(1)
    view.leftToSuperview(offset: margin)
    view.rightToSuperview(offset: margin)
    return view
  }
}

class TransactionViewController: UIViewController {
  
  let transaction: WalletTransaction
  
  let scrollView = UIScrollView()
  
  let amountLabel = UILabel()
  
  let directionLabel = UILabel()
  
  let directionImageView = UIImageView()
  
  let addressTypeLabel = UILabel()
  
  let addressLabel = UILabel()
  
  let dateTitleLabel = UILabel()
  
  let dateLabel = UILabel()
  
  let relativeDateLabel = UILabel()
  
  let confirmationLabel = UILabel()
  
  let txidTitleLabel = UILabel()
  
  let txidLabel = UILabel()
  
  let feeLabel = UILabel()

  init(transaction: WalletTransaction) {
    self.transaction = transaction
    super.init(nibName: nil, bundle: nil)
    self.render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    view.addSubview(scrollView)
    scrollView.addSubview(directionLabel)
    scrollView.addSubview(directionImageView)
    scrollView.addSubview(amountLabel)
    scrollView.addSubview(addressTypeLabel)
    scrollView.addSubview(addressLabel)
    scrollView.addSubview(dateTitleLabel)
    scrollView.addSubview(dateLabel)
    scrollView.addSubview(relativeDateLabel)
    scrollView.addSubview(confirmationLabel)
    scrollView.addSubview(txidTitleLabel)
    scrollView.addSubview(txidLabel)
    scrollView.addSubview(feeLabel)
    
    scrollView.edgesToSuperview(usingSafeArea: true)
    scrollView.width(UIScreen.main.bounds.width)
    
    let margin: CGFloat = 24
    directionImageView.leftToSuperview(offset: margin)
    directionImageView.topToSuperview(offset: margin)
    directionLabel.centerY(to: directionImageView)
    directionLabel.leftToRight(of: directionImageView, offset: margin)
    
    directionLabel.text = transaction.direction == .out ? "Sent" : "Received"
    directionLabel.font = UIFont.monserrat(with: 18)
    directionImageView.image = transaction.direction == .out ? #imageLiteral(resourceName: "sent_icon") : #imageLiteral(resourceName: "received_icon")
    
    directionImageView.height(33)
    directionImageView.width(33)
    
    let amount = abs(transaction.feelessAmount)
    let amountStr = String(format: "%0.8f", Double(amount) * 1e-8)
    amountLabel.text = "\(amountStr) FSC"
    amountLabel.font = UIFont.monserrat(with: 32)
    amountLabel.topToBottom(of: directionImageView, offset: margin)
    amountLabel.left(to: directionImageView)
    
    let amountSeparator = UIView.separator(superview: scrollView, margin: margin)
    
    if transaction.direction == .out {
      feeLabel.topToBottom(of: amountLabel, offset: 8)
      let feeStr = String(format: "%0.8f", Double(transaction.fee) * 1e-8)
      feeLabel.text = "Fee: \(feeStr)"
      feeLabel.textColor = UIColor(white: 0.4, alpha: 1)
      feeLabel.leftToSuperview(offset: margin)
      amountSeparator.topToBottom(of: feeLabel, offset: margin)
    } else {
      amountSeparator.topToBottom(of: amountLabel, offset: margin)
    }

    addressTypeLabel.text = transaction.direction == .out ? "Sent To" : "Received To"
    addressTypeLabel.topToBottom(of: amountSeparator, offset: margin)
    addressTypeLabel.left(to: amountLabel)
    addressTypeLabel.font = UIFont.monserrat(with: 18)
    
    let address: String
    
    if transaction.direction == .in {
      address = transaction.transaction.inputAddresses.first ?? ""
    } else {
      let outputAddresses = transaction.transaction.outputAddresses
      let inputAddresses = transaction.transaction.inputAddresses
      let missing = outputAddresses.filter { !inputAddresses.contains($0) }
      address = missing.first ?? ""
    }
    
    addressLabel.text = address
    addressLabel.left(to: addressTypeLabel)
    addressLabel.rightToSuperview(offset: margin)
    addressLabel.numberOfLines = 1
    addressLabel.topToBottom(of: addressTypeLabel, offset: 4)
    addressLabel.font = UIFont.monserrat(with: 15)
    addressLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
    addressLabel.adjustsFontSizeToFitWidth = true
    addressLabel.minimumScaleFactor = 0.8
    addressLabel.width(UIScreen.main.bounds.width - (margin * 2))
    
    let addressSeparator = UIView.separator(superview: scrollView, margin: margin)
    addressSeparator.topToBottom(of: addressLabel, offset: margin)
    
    dateTitleLabel.text = "Date"
    dateTitleLabel.font = UIFont.monserrat(with: 18)
    dateTitleLabel.leftToSuperview(offset: margin)
    dateTitleLabel.topToBottom(of: addressSeparator, offset: margin)
    
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    dateLabel.text = formatter.string(from: transaction.date)
    dateLabel.topToBottom(of: dateTitleLabel, offset: 4)
    dateLabel.font = UIFont.monserrat(with: 15)
    dateLabel.left(to: dateTitleLabel)
    dateLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
    
    relativeDateLabel.text = moment(transaction.date).fromNow()
    relativeDateLabel.font = UIFont.monserrat(with: 12)
    relativeDateLabel.textColor = UIColor(white: 0.4, alpha: 1.0)
    relativeDateLabel.topToBottom(of: dateLabel, offset: 4)
    relativeDateLabel.left(to: dateLabel)
    
    let dateSeparator = UIView.separator(superview: scrollView, margin: margin)
    dateSeparator.topToBottom(of: relativeDateLabel, offset: margin)
    
    confirmationLabel.topToBottom(of: dateSeparator, offset: margin)
    confirmationLabel.leftToSuperview(offset: margin)
    confirmationLabel.font = UIFont.monserrat(with: 24)
    
    let depth = NetworkManager.shared.depth(of: transaction.transaction.blockHash, max: 6)
    let depthText = depth >= 6 ? "6+" : "\(depth)"
    
    confirmationLabel.text = "\(depthText) Confirmations"
    
    let confirmationSeparator = UIView.separator(superview: scrollView, margin: margin)
    confirmationSeparator.topToBottom(of: confirmationLabel, offset: margin)
    
    txidTitleLabel.text = "Transaction ID"
    txidTitleLabel.font = UIFont.monserrat(with: 18)
    txidTitleLabel.leftToSuperview(offset: margin)
    txidTitleLabel.topToBottom(of: confirmationSeparator, offset: margin)
    
    txidLabel.text = transaction.id
    txidLabel.left(to: addressTypeLabel)
    txidLabel.rightToSuperview(offset: margin)
    txidLabel.numberOfLines = 0
    txidLabel.topToBottom(of: txidTitleLabel, offset: 4)
    txidLabel.font = UIFont.monserrat(with: 15)
    txidLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
    txidLabel.lineBreakMode = .byCharWrapping
    txidLabel.width(UIScreen.main.bounds.width - (margin * 2))
    
    let txidTap = UITapGestureRecognizer(target: self, action: #selector(onTxidTap))
    txidLabel.addGestureRecognizer(txidTap)
    txidLabel.isUserInteractionEnabled = true
    
    txidLabel.bottomToSuperview(offset: -margin)
  }
  
  @objc
  func onTxidTap() {
    UIPasteboard.general.string = transaction.id
    var style = ToastStyle()
    style.messageFont = UIFont.monserrat(with: 18)
    view.makeToast("Copied", position: .bottom, style: style)
  }
}

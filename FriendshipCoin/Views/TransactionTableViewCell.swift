//
//  TransactionTableViewCell.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 01/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import SwiftMoment
import TinyConstraints

class TransactionTableViewCell: UITableViewCell {
  
  var transaction: WalletTransaction? {
    didSet {
      self.configure()
    }
  }
  
  let typeLabel = UILabel()
  
  let typeIndicator = UIView()
  
  let amountLabel = UILabel()
 
  let timeLabel = UILabel()
  
  let accountLabel = UILabel()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    contentView.addSubview(typeLabel)
    contentView.addSubview(typeIndicator)
    contentView.addSubview(amountLabel)
    contentView.addSubview(timeLabel)
    contentView.addSubview(accountLabel)
    
    let margin: CGFloat = 15
    typeLabel.leftToSuperview(offset: margin)
    typeLabel.topToSuperview(offset: margin)
    typeLabel.font = UIFont.monserrat(with: 14)
//    typeLabel.textColor = UIColor.darkGray
    
    typeIndicator.width(margin)
    typeIndicator.left(to: typeLabel)
    typeIndicator.height(margin)
    typeIndicator.topToBottom(of: typeLabel, offset: margin / 2)
    typeIndicator.layer.cornerRadius = margin / 2
    typeIndicator.bottomToSuperview(offset: -margin)
    
    amountLabel.rightToSuperview(offset: margin)
    amountLabel.font = UIFont.monserrat(with: 16)
//    amountLabel.textColor = UIColor.darkGray
    
    amountLabel.leftToRight(of: typeLabel, offset: margin, relation: TinyConstraints.ConstraintRelation.equalOrGreater, priority: LayoutPriority.defaultHigh)
    amountLabel.top(to: typeLabel)
    
    timeLabel.topToBottom(of: amountLabel, offset: margin / 4)
    timeLabel.right(to: amountLabel)
    timeLabel.font = UIFont.monserrat(with: 12)
    timeLabel.textColor = UIColor.darkGray
    
    accountLabel.leftToRight(of: typeIndicator, offset: margin / 2)
    accountLabel.centerY(to: typeIndicator)
    accountLabel.font = UIFont.monserrat(with: 12)
    accountLabel.textColor = UIColor.darkGray
    
  }
  
  func configure() {
    guard let transaction = self.transaction else { return }
    typeLabel.text = transaction.direction == .in ? "Payment Received" : "Payment Sent"
    typeIndicator.backgroundColor = transaction.direction == .in ? UIColor.green : UIColor.red
    amountLabel.text = "\(transaction.formattedAmount) FSC"
    timeLabel.text = moment(transaction.time).fromNow()
    accountLabel.text = "Main Account"
  }
}

extension TransactionTableViewCell: ReusableCell {}

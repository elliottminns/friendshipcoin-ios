//
//  InputFieldView.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 30/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

class InputFieldView: UIView {
  
  let label: String
  
  let placeholder: String
  
  var text: String? {
    get {
      return textField.text
    }
    set {
      textField.text = newValue
    }
  }
  
  fileprivate(set) var textField = UITextField()
  
  fileprivate(set) var fieldLabel = UILabel()

  init(label: String, placeholder: String) {
    self.label = label
    self.placeholder = placeholder
    super.init(frame: .zero)
    self.render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    sv([fieldLabel, textField])
    
    let margin: CGFloat = 8
    fieldLabel.topToSuperview()
    fieldLabel.bottomToSuperview()
    fieldLabel.leftToSuperview(offset: margin)
    fieldLabel.text = label
    fieldLabel.font = UIFont.monserrat(with: 16, bold: true)
    fieldLabel.textColor = UIColor.fscBlue
    fieldLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    textField.leftToRight(of: fieldLabel, offset: margin)
    textField.rightToSuperview(offset: margin)
    textField.centerY(to: fieldLabel)
    textField.font = UIFont.monserrat(with: 16)
    textField.placeholder = placeholder
  }
  
  override func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    return textField.resignFirstResponder()
  }
  
  override func becomeFirstResponder() -> Bool {
    super.becomeFirstResponder()
    return textField.becomeFirstResponder()
  }
  
}

//
//  NumberPadView.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 29/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import Stevia

enum NumberPadViewKey {
  case number(Int)
  case backspace
  case decimal
}

extension NumberPadViewKey {
  var title: String {
    switch self {
    case .number(let value): return "\(value)"
    case .backspace: return "⌫"
    case .decimal: return "."
    }
  }
}

protocol NumberPadDelegate {
  func numberPad(view: NumberPadView, didSelectNumber key: NumberPadViewKey)
}

class NumberPadView: UIView {
  
  fileprivate var buttonHash: [UIButton: NumberPadViewKey] = [:]
  
  var delegate: NumberPadDelegate?
  
  let buttons: [NumberPadViewKey] = [
    .number(1), .number(2), .number(3),
    .number(4), .number(5), .number(6),
    .number(7), .number(8), .number(9),
    .decimal, .number(0), .backspace
  ]
  
  init() {
    super.init(frame: .zero)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    let numRows = 4
    let numCols = 3
    
    let range = 0 ..< numRows
    let rows = range.map { (index: Int) -> [NumberPadViewKey] in
      let start = index * numCols
      let end = start + numCols
      let range = start ..< end
      return Array(self.buttons[range])
    }
    
    let columns = rows.map(stack(for:))
    let stack = UIStackView()
    stack.alignment = .fill
    stack.axis = .vertical
    stack.distribution = .fillEqually
    columns.forEach(stack.addArrangedSubview)
    columns.forEach {
      $0.leftToSuperview()
      $0.rightToSuperview()
    }
    sv(stack)
    stack.edgesToSuperview()
  }
  
  func stack(for row: [NumberPadViewKey]) -> UIStackView {
    let stack = UIStackView()
    stack.alignment = .fill
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    
    let buttons = row.map { (key: NumberPadViewKey) -> UIButton in
      let button = UIButton()
      button.fscInverted()
      button.titleLabel?.font = UIFont.monserrat(with: 24)
      button.setTitle(key.title, for: [])
      button.addTarget(self, action: #selector(buttonTapped(sender:)),
                       for: .touchUpInside)
      buttonHash[button] = key
      return button
    }
    
    buttons.forEach(stack.addArrangedSubview)
    return stack
  }
  
  @objc
  func buttonTapped(sender: UIButton) {
    guard let key = buttonHash[sender] else { return }
    delegate?.numberPad(view: self, didSelectNumber: key)
  }
}

//
//  ReceiveViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 26/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import Stevia
import QRCode

class ReceiveViewController: UIViewController {
  
  let account: Account
  
  let wallet: Wallet
  
  let titleLabel = UILabel()
  
  let addressLabel = UILabel()
  
  let copiedLabel = UILabel()
  
  let addressView = UIView()
  
  let qrImageView = UIImageView()
  
  let stackView = UIStackView()
  
  let amountField = UITextField()
  
  let amountView = UIView()
  
  let scrollView = UIScrollView()
  
  let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  var address: String {
    didSet {
      updateQR()
      self.addressLabel.text = address
    }
  }
  
  init(account: Account, wallet: Wallet) {
    self.account = account
    self.address = ""
    self.wallet = wallet
    super.init(nibName: nil, bundle: nil)
    self.render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
    title = "Receive Payment"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close",
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(close))
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePressed))
    
    let screenTap = UITapGestureRecognizer(target: amountField, action: #selector(resignFirstResponder))
    view.addGestureRecognizer(screenTap)
    
    view.sv(scrollView)
    scrollView.edgesToSuperview(usingSafeArea: true)
    scrollView.sv(stackView)

    addressView.sv(titleLabel)
    addressView.sv(addressLabel)
    addressView.sv(copiedLabel)

    titleLabel.font = UIFont.monserrat(with: 14)
    titleLabel.text = "Address"
    titleLabel.textColor = UIColor(white: 0.15, alpha: 1.0)
    
    addressLabel.centerInSuperview()
    addressLabel.width(90%)
    addressLabel.font = UIFont.titleFont(with: 16)
    addressLabel.numberOfLines = 0
    addressLabel.text = ""
    addressLabel.textAlignment = .center
    
    addressLabel.isUserInteractionEnabled = true
    addressLabel.addGestureRecognizer(tap)
    
    copiedLabel.alpha = 0
    copiedLabel.textColor = UIColor.fscBlue
    copiedLabel.font = UIFont.monserrat(with: 12, bold: true)
    copiedLabel.centerHorizontally()
    copiedLabel.topToBottom(of: addressLabel, offset: 4)
    copiedLabel.text = "Copied"
    
    titleLabel.centerHorizontally()
    titleLabel.bottomToTop(of: addressLabel, offset: -8)
    
    DispatchQueue.global().async {
      let unused = self.wallet.unusedAddress(for: self.account)
      DispatchQueue.main.async {
        self.address = unused
      }
    }
    
    self.addressView.height(120)

    qrImageView.height(200)
    qrImageView.contentMode = .scaleAspectFit
    qrImageView.addSubview(loadingIndicator)
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.startAnimating()
    loadingIndicator.centerInSuperview()

    stackView.addArrangedSubview(amountView)
    stackView.addArrangedSubview(qrImageView)
    stackView.addArrangedSubview(addressView)

    
    amountView.sv(amountField)
    
    amountField.placeholder = "Amount"
    amountField.font = UIFont.monserrat(with: 18)
    amountField.keyboardType = .decimalPad
    amountField.textAlignment = .center
    amountField.leftToSuperview(offset: 12)
    amountField.rightToSuperview(offset: 12)
    amountField.centerHorizontally()
    amountField.height(49)
    amountField.topToSuperview(offset: 0)
    amountField.bottomToSuperview(offset: 2)
    amountField.addTarget(self, action: #selector(amountFieldDidChange), for: .editingChanged)
    amountField.delegate = self
    
    amountView.width(75%)
    amountView.height(53)
    amountView.layer.borderWidth = 1.0
    amountView.layer.cornerRadius = 8
    amountView.layer.borderColor = UIColor.fscBlue.cgColor

    stackView.axis = .vertical
    stackView.distribution = .fillProportionally
    stackView.alignment = .center
    stackView.spacing = 12
    stackView.width(to: view)
    stackView.topToSuperview(offset: 12)
    stackView.leftToSuperview()
    stackView.rightToSuperview()
    stackView.bottom(to: scrollView, offset: 20)
    stackView.backgroundColor = UIColor.red
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    registerKeyboardNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func close() {
    amountField.resignFirstResponder()
    dismiss(animated: true, completion: nil)
  }
  
  @objc
  func onTap() {
    amountField.resignFirstResponder()
    UIPasteboard.general.string = addressLabel.text
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
      self.copiedLabel.alpha = 1.0
    }, completion: { _ in
      UIView.animate(withDuration: 0.5, delay: 0.75, options: [.curveEaseInOut], animations: {
        self.copiedLabel.alpha = 0.0
      }, completion: nil)
    })
  }
  
  func registerKeyboardNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow(notification:)),
                                           name: NSNotification.Name.UIKeyboardWillShow,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide(notification:)),
                                           name: NSNotification.Name.UIKeyboardWillHide,
                                           object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  func keyboardWillShow(notification: NSNotification) {
    let userInfo: NSDictionary = notification.userInfo! as NSDictionary
    let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
    let keyboardSize = keyboardInfo.cgRectValue.size
    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
    scrollView.contentInset = contentInsets
    scrollView.scrollIndicatorInsets = contentInsets
  }
  
  @objc
  func keyboardWillHide(notification: NSNotification) {
    scrollView.contentInset = .zero
    scrollView.scrollIndicatorInsets = .zero
  }
  
  @objc
  func amountFieldDidChange(textField: UITextField) {
    updateQR()
  }
  
  func updateQR() {
    let string = "friendshipcoin:\(self.address)"
    let additions: String = {
      var additions = "?"
      if let amount = self.amountField.text {
        additions = "\(additions)amount=\(amount)"
      }
      
      if additions.count == 1 { return "" }
      return additions
    }()
    
    let code = string + additions
    DispatchQueue.global().async {
      let qr = QRCode(code)
      
      
      if let image = qr?.image {
        DispatchQueue.main.async {
          self.loadingIndicator.stopAnimating()
          self.qrImageView.image = image
          self.qrImageView.height(image.size.height)
        }
      }
    }
  }
  
  @objc
  func sharePressed() {
    let address = self.address
    let controller = UIActivityViewController(activityItems: [address],
                                              applicationActivities: nil)
    present(controller, animated: true, completion: nil)
  }
}

extension ReceiveViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return textField.isAllowedCurrencyEdit(range: range,
                                           replacementString: string)
  }
}

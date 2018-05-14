//
//  SendViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 30/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import QRCodeReader
import CoinKit

class SendViewController: UIViewController {
  
  let account: Account
  
  let wallet: Wallet
  
  let scrollView = UIScrollView()
  
  let confirmButton = UIButton()
  
  let availableLabel = UILabel()
  
  let amountField = InputFieldView(label: "Amount", placeholder: "0.00")
  
  let addressField = InputFieldView(label: "Address", placeholder: "Friendship coin address")
  
  let fscLabel = UILabel()
  
  let amountView = UIView()
  
  lazy var readerVC: QRCodeReaderViewController = {
    let builder = QRCodeReaderViewControllerBuilder {
      $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
    }
    
    return QRCodeReaderViewController(builder: builder)
  }()
  
  init(account: Account, wallet: Wallet) {
    self.account = account
    self.wallet = wallet
    super.init(nibName: nil, bundle: nil)
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
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "QRCode"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(onQRCode))
    
    view.sv(scrollView)
    
    scrollView.edgesToSuperview(usingSafeArea: true)
    
    scrollView.sv([availableLabel, amountField, addressField, confirmButton])
    
    let margin: CGFloat = 8
    
    availableLabel.width(to: view, view.widthAnchor)
    availableLabel.leftToSuperview()
    availableLabel.rightToSuperview()
    availableLabel.centerHorizontally()
    availableLabel.textAlignment = .center
    availableLabel.text = "\(account.totalBalance) Available"
    availableLabel.font = UIFont.monserrat(with: 14, bold: false)
    availableLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
    availableLabel.topToSuperview(offset: margin * 2, usingSafeArea: true)
    availableLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    
    confirmButton.backgroundColor = UIColor.fscBlue
    confirmButton.setTitle("Confirm", for: [])
    confirmButton.addTarget(self, action: #selector(confirmButtonPressed), for: .touchUpInside)
    
    confirmButton.leftToSuperview(offset: margin)
    confirmButton.rightToSuperview(offset: margin)
    confirmButton.bottom(to: scrollView, offset: margin)

    confirmButton.fscStyle()
    confirmButton.height(54.0)
    confirmButton.titleLabel?.font = UIFont.titleFont(with: 18)
    
    let amountSep = createSeperator()
    amountSep.topToBottom(of: availableLabel, offset: margin * 2)
    
    let bottomSep = createSeperator()
    bottomSep.topToBottom(of: addressField, offset: margin)
    
    amountField.leftToSuperview()
    amountField.rightToSuperview()
    amountField.topToBottom(of: bottomSep, offset: margin)
    amountField.textField.keyboardType = .decimalPad
    amountField.height(44)
    amountField.textField.delegate = self

    addressField.leftToSuperview()
    addressField.rightToSuperview()
    addressField.topToBottom(of: amountSep, offset: margin)
    addressField.height(44)
    addressField.textField.delegate = self
    addressField.textField.autocorrectionType = .no
    addressField.textField.autocapitalizationType = .none
    
    addressField.textField.returnKeyType = .next

    let addressSep = createSeperator()
    addressSep.topToBottom(of: amountField, offset: margin)
    
    confirmButton.topToBottom(of: addressSep, offset: margin * 2)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    _ = addressField.becomeFirstResponder()
  }
}

extension SendViewController {
  @objc
  func close() {
    view.endEditing(true)
    dismiss(animated: true, completion: nil)
  }
  
  @objc
  func onQRCode() {
    readerVC.delegate = self
    
    // Presents the readerVC as modal form sheet
    readerVC.modalPresentationStyle = .formSheet
    present(readerVC, animated: true, completion: nil)
  }
  
  @objc
  func confirmButtonPressed() {
    let fee = UInt64(1e4)
    guard let address = self.addressField.text,
      let amountDouble = Double(self.amountField.text ?? "") else { return }
    
    
    let amount = UInt64(amountDouble * Coin.modifier)
    let total = amount + fee
    
    var balance: UInt64 = 0
    let utxos = wallet.utxos.filter { utxo in
      if balance < total {
        balance = balance + utxo.amount
        return true
      } else {
        return false
      }
    }
    
    let delta = balance - total

    let builder = TransactionBuilder<FSCTransaction>(network: NetworkType.friendshipcoin)
    do {
      try builder.add(output: address, amount: amount)
      
      if delta > 0 {
        let change = wallet.unusedAddress(for: account)
        try builder.add(output: change, amount: delta)
      }
      
      try utxos.forEach { utxo in
        try builder.add(input: utxo.transaction, outputIndex: utxo.outputIndex)
      }
      
      let addresses = utxos.map { $0.address }
      let addressIndexes = try addresses.map { try wallet.index(of: $0, in: account) }
      
      let tx = try builder.build()
      try addressIndexes.enumerated().forEach { item in
        let vin = item.offset
        let addressIndex = item.element
        let keyPair = try KeyManager.shared.keyPair(for: account, address: addressIndex)
        try builder.sign(transaction: tx, vin: vin, keyPair: keyPair)
      }

      let transaction = try builder.build()
      NetworkManager.shared.broadcast(transaction: transaction)
      
      // Tell the wallet to hold the funds
      wallet.lock(utxos: utxos)
      wallet.add(pending: transaction)
      
      dismiss(animated: true, completion: nil)
    } catch let err {
      let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
      controller.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
      present(controller, animated: true, completion: nil)
    }
  }
}

extension SendViewController: QRCodeReaderViewControllerDelegate {
  func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    reader.stopScanning()
    let value = result.value
    let bip21 = Bip21URI(uri: value)
    
    self.amountField.textField.text = bip21?.amount
    self.addressField.textField.text = bip21?.address
    
    dismiss(animated: true, completion: nil)
  }
  
  func readerDidCancel(_ reader: QRCodeReaderViewController) {
    reader.stopScanning()
    
    dismiss(animated: true, completion: nil)
  }
}

extension SendViewController {
  func createSeperator() -> UIView {
    let view = UIView()
    scrollView.sv(view)
    view.height(0.5)
    view.leftToSuperview()
    view.rightToSuperview()
    view.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
    return view
  }
}

extension SendViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    if textField == amountField.textField {
      return textField.isAllowedCurrencyEdit(range: range,
                                             replacementString: string)
    }
    
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == addressField.textField {
      _ = amountField.becomeFirstResponder()
      return false
    }
    
    return true
  }
}

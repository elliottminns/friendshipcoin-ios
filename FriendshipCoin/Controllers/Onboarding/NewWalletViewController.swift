//
//  NewWalletViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 24/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import CoinKit
import Stevia

class NewWalletViewController: UIViewController {
  
  enum ControllerType {
    case newWallet
    case seedView
  }
  
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  let stackView = UIStackView()
  
  let words = UILabel()
  
  let titleLabel = UILabel()
  
  let readyButton = UIButton()
  
  let type: ControllerType
  
  var mnemonic: Mnemonic? {
    didSet {
      self.reloadMnemonic()
    }
  }
  
  func reloadMnemonic() {
    guard let mnemonic = mnemonic else { return }
    self.activityIndicator.stopAnimating()
    words.text = mnemonic.words.enumerated().reduce("", { (result, ele) -> String in
      if ele.offset == 0 {
        return ele.element
      } else if ele.offset % 4 == 0 {
        return "\(result)\n\n\(ele.element)"
      } else {
        return "\(result)  \(ele.element)"
      }
    })
    stackView.isHidden = false
  }

  init() {
    type = .newWallet
    super.init(nibName: nil, bundle: nil)
    title = "New Wallet"
    render()
  }
  
  init(mnemonic: Mnemonic) {
    type = .seedView
    self.mnemonic = mnemonic
    super.init(nibName: nil, bundle: nil)
    title = "My Seed"
    render()
    reloadMnemonic()
    self.readyButton.isHidden = true
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    view.sv(activityIndicator, stackView)
    
    activityIndicator.hidesWhenStopped = true
    activityIndicator.startAnimating()
    activityIndicator.center(in: view)
    
    stackView.axis = .vertical
    stackView.distribution = .equalCentering
    stackView.alignment = .center
    stackView.spacing = 36
    
    stackView.centerInSuperview()
    stackView.left(to: view, view.safeAreaLayoutGuide.leftAnchor, offset: 12)
    stackView.right(to: view, view.safeAreaLayoutGuide.rightAnchor, offset: -12)
    
    titleLabel.text = "Please write down the below words and keep them safe."
    titleLabel.font = UIFont.monserrat(with: 18, bold: true)
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.textColor = UIColor(white: 0.15, alpha: 1.0)
    
    words.font = UIFont.monserrat(with: 18)
    words.textAlignment = .center
    words.numberOfLines = 0
    
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(words)
    stackView.addArrangedSubview(readyButton)
    stackView.isHidden = true
    
    readyButton.fscStyle()
    readyButton.setTitle("Ready", for: .normal)
    readyButton.width(180)
    readyButton.height(44)
    readyButton.addTarget(self, action: #selector(readyButtonPressed(sender:)),
                          for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard self.mnemonic == nil else {
      self.activityIndicator.stopAnimating()
      return
    }
    DispatchQueue.global().async {
      do {
        let mnemonic = try Mnemonic()
        DispatchQueue.main.async {
          self.mnemonic = mnemonic
        }
      } catch let error {
        print(error)
      }
    }
    activityIndicator.stopAnimating()
  }
  
  @objc func readyButtonPressed(sender: UIButton) {
    guard type == .newWallet else {
      self.navigationController?.popViewController(animated: true)
      return
    }
    guard let mnemonic = mnemonic else { return }
    KeyManager.shared.store(mnemonic: mnemonic)
    let account = try! KeyManager.shared.getPublicBase58(account: 0)
    NetworkManager.shared.wallet.addAccount(for: account, index: 0) { _ in
      self.dismiss(animated: true, completion: nil)
    }
  }
}

//
//  OnboardingViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import Stevia
import TinyConstraints

class OnboardingViewController: UIViewController {
  let newWalletButton = UIButton()
  let restoreWalletButton = UIButton()
  let icon = UIImageView()
  let titleLabel = UILabel()
  let descriptionLabel = UILabel()
  let stack = UIStackView()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    self.render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    view.sv(stack)
    stack.left(to: view, view.safeAreaLayoutGuide.leftAnchor)
    stack.right(to: view, view.safeAreaLayoutGuide.rightAnchor)
    stack.centerVertically()
    stack.spacing = 12
    
    stack.addArrangedSubview(icon)
    stack.addArrangedSubview(titleLabel)
    stack.addArrangedSubview(descriptionLabel)
    stack.addArrangedSubview(newWalletButton)
    stack.addArrangedSubview(restoreWalletButton)
    stack.alignment = .center
    stack.axis = .vertical
    stack.distribution = .equalCentering
    
    icon.image = #imageLiteral(resourceName: "Logo")
    icon.width(120).height(120)
    
    titleLabel.text = "Friendship Coin"
    titleLabel.font = UIFont.titleFont(with: 24)
    
    descriptionLabel.text = "Start by creating a new wallet or\nrestoring one from backup."
    descriptionLabel.font = UIFont.monserrat(with: 16)
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .center
    
    styleButton(button: newWalletButton)
    styleButton(button: restoreWalletButton)
    
    newWalletButton.setTitle("New Wallet", for: [])
    newWalletButton.height(49)
    newWalletButton.titleLabel?.font = UIFont.monserrat(with: 18)
    newWalletButton.addTarget(self,
                              action: #selector(newWalletButtonPressed(sender:)),
                              for: UIControlEvents.touchUpInside)
    
    restoreWalletButton.setTitle("Restore from backup", for: [])
    restoreWalletButton.height(44)
    restoreWalletButton.titleLabel?.font = UIFont.monserrat(with: 14)
    restoreWalletButton.addTarget(self,
                                  action: #selector(restoreWalletButtonPressed(sender:)),
                                  for: .touchUpInside)
  }
  
  func styleButton(button: UIButton) {
    button.fscStyle()
    button.width(180)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  @objc
  func newWalletButtonPressed(sender: UIButton) {
    let controller = NewWalletViewController()
    navigationController?.pushViewController(controller, animated: true)
  }
  
  @objc
  func restoreWalletButtonPressed(sender: UIButton) {
    let controller = RestoreWalletViewController()
    navigationController?.pushViewController(controller, animated: true)
  }
}

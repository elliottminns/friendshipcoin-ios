//
//  OnboardingNavigationViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

class OnboardingNavigationViewController: UINavigationController {
  
  init() {
    let root = OnboardingViewController()
    super.init(nibName: nil, bundle: nil)
    self.viewControllers = [root]
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

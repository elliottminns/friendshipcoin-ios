//
//  SettingsViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  let tableViewController = SettingsTableViewController()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    self.title = "Settings"
    self.tabBarItem.image = #imageLiteral(resourceName: "settings")
    self.render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
    addChildViewController(tableViewController)
    view.addSubview(tableViewController.view)
    tableViewController.view.edgesToSuperview(usingSafeArea: true)
  }
}

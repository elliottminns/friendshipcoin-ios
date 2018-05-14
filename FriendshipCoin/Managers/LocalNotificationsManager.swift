//
//  LocalNotificationsManager.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 14/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UserNotifications
import UserNotificationsUI

class LocalNotificationsManager {
  
  static let `default` = LocalNotificationsManager()
  
  fileprivate init() {
  }
  
  func setup() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onWalletScan(notification:)),
                                           name: Wallet.Notifications.scanningEnded,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(incomingTransaction(notification:)),
                                           name: NetworkManager.Notifications.incomingTransaction,
                                           object: nil)
  }
  
}

extension LocalNotificationsManager {
  
  @objc
  func onWalletScan(notification: Notification) {
    guard let debits = notification.userInfo?["debits"] as? [WalletDebit],
      let credits = notification.userInfo?["credits"] as? [WalletCredit],
      (debits.count > 0 || credits.count > 0) else {
        return
    }
    
    let total = Int64(credits.amount) - Int64(debits.amount)
    
    let title: String
    let body: String
    
    if total < 0 {
      title = "Sent Funds"
      body = "\(Double(-total) * 1e-8) FSC"
    } else {
      title = "Received Funds"
      body = "\(Double(total) * 1e-8) FSC"
    }
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    
    let identifier = UUID().uuidString
    let localNotification = UNNotificationRequest(identifier: identifier,
                                                  content: content,
                                                  trigger: nil)
    
    UNUserNotificationCenter.current().add(localNotification) { _ in
    }
  }
  
  @objc
  func incomingTransaction(notification: Notification) {
    guard let amount = notification.userInfo?["amount"] as? Int64 else { return }
    let title: String = "Incoming transaction"
    let body: String = "\(Double(amount) * 1e-8) FSC"
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    
    let identifier = UUID().uuidString
    let localNotification = UNNotificationRequest(identifier: identifier,
                                                  content: content,
                                                  trigger: nil)
    
    UNUserNotificationCenter.current().add(localNotification) { _ in
    }
  }
}

//
//  AppDelegate.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import CoinKit
import UserNotifications
import ToastSwiftFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  var peers: Network?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)

    NetworkManager.shared.connect()
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    center.requestAuthorization(options: [.alert, .sound, .badge]) {
      (granted, error) in
      // Enable or disable features based on authorization.
      if granted {
        // update application settings
      }
    }
    LocalNotificationsManager.default.setup()
    
    let controllers: [UIViewController] = [
      UINavigationController(rootViewController: BalanceViewController()),
      //UINavigationController(rootViewController: AccountsViewController()),
      UINavigationController(rootViewController: TransactionsTableViewController()),
      UINavigationController(rootViewController: SettingsViewController())
    ]
    let tab = TabBarController(controllers: controllers)
    
    window?.rootViewController = tab
    window?.makeKeyAndVisible()

    if !KeyManager.shared.hasKeys {
      let onboarding = OnboardingNavigationViewController()
      tab.present(onboarding, animated: false, completion: nil)
    }
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _ = application.beginBackgroundTask {
      
    }
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
    guard let tab = window?.rootViewController as? TabBarController else {
      return completionHandler([.sound, .alert])
    }
    
    var style = ToastStyle()
    style.titleAlignment = .center
    style.messageAlignment = .center
    style.titleFont = UIFont.titleFont(with: 18)
    style.messageFont = UIFont.monserrat(with: 18)
    
    tab.view.makeToast(notification.request.content.body,
                       duration: 5,
                       position: .top,
                       title: notification.request.content.title,
                       style: style)
  }
}

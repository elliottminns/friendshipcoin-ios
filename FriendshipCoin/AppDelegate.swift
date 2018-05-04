//
//  AppDelegate.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import CoinKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  var peers: Network?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
/*
    let privateKey = "74dc5e05ca5303ee2fce5f92fa0c4ceb877c836b21ef594c919ed4356a1cde0e".hexadecimal()!
    let hash = Data("4e3a52a33ad8b76f21b2dc81c079c7c59aa717d7c98adeafb9f3f7bd07572d22".hexadecimal()!.reversed())
    
    let curve = Secp256k1()
    curve.sign(hash: hash, privateKey: privateKey)
     
    let hex = "010000000dbcec5a01d0a07e12664aaafe4fcb9c07745ccf3ee3c5bf0e04787d3b23c3ba25db945a450100000000ffffffff0220a10700000000001976a914fd81fb638baecbeda3f7baa94c249821d760194188ac301b0f00000000001976a91427ae118d24465dd203655f309533b1841f73e0e588ac00000000".components(separatedBy: " ").joined().hexadecimal()!
    let transaction = try! FSCTransaction(data: hex)
    let builder = TransactionBuilder<FSCTransaction>(transaction: transaction, network: NetworkType.friendshipcoin)
    let tx = try! builder.build()
    print(tx.toData().hexEncodedString())
    
    let keypair = try! KeyManager.shared.keyPair(for: NetworkManager.shared.wallet.accounts[0], address: 1)
    try! builder.sign(transaction: tx, vin: 0, keyPair: keypair)
    let tx2 = try! builder.build()
    print(tx2.toData().hexEncodedString())
    */

    NetworkManager.shared.connect()
    
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

//
//  SettingsTableViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 19/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit
import CoinKit

class SettingsTableViewController: UITableViewController {
  
  let settings: [SettingSectionViewModel] = [
    SettingSectionViewModel(settings: [.seed, .rescanTxns], title: "Backup"),
    SettingSectionViewModel(settings: [.version], title: "About")
  ]
  
  init() {
    super.init(nibName: nil, bundle: nil)
    tableView.register(cellClass: SettingDisplayTableViewCell.self)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return settings.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settings[section].settings.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = self.settings[indexPath.section][indexPath.row]
    return self.cell(for: setting, tableView: tableView, indexPath: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return settings[section].title
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let setting = settings[indexPath.section].settings[indexPath.row]
    if setting == .seed {
      guard let words = try? KeyManager.shared.privKeychain.get("words") else { return }
      let mnemonic = Mnemonic(words: words ?? "")
      let controller = NewWalletViewController(mnemonic: mnemonic)
      navigationController?.pushViewController(controller, animated: true)
    } else if setting == .rescanTxns {
      let wallet = NetworkManager.shared.wallet
      wallet.scanQueue.async {
        wallet.lastBlockScanned = NetworkManager.shared.blockchain.genesis.hash
        NetworkManager.shared.wallet.scanForBalances {
          
        }
      }
    }
  }
}

extension SettingsTableViewController {
  
  func cell(for setting: Setting, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    switch setting {
    case .seed:
      let cell = tableView.dequeReusableCell(for: SettingDisplayTableViewCell.self, for: indexPath)
      cell.textLabel?.text = "View backup"
      cell.accessoryType = .disclosureIndicator
      cell.imageView?.image = #imageLiteral(resourceName: "lock_icon")
      return cell
    case .version:
      let cell = tableView.dequeReusableCell(for: SettingDisplayTableViewCell.self, for: indexPath)
      cell.imageView?.image = #imageLiteral(resourceName: "version_icon")
      cell.textLabel?.text = "Version"
      cell.detailTextLabel?.text = "1.0.0"
      return cell
    case .rescanTxns:
      let cell = tableView.dequeReusableCell(for: SettingDisplayTableViewCell.self, for: indexPath)
      cell.textLabel?.text = "Rescan for all transactions"
      cell.imageView?.image = #imageLiteral(resourceName: "transactions")
      return cell
    }
  }
}

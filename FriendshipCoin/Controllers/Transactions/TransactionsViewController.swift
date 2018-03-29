//
//  TransactionsViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

class TransactionsViewController: UITableViewController {
  
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
  }()
  
  var transactions: [AccountTransaction] = [] {
    didSet {
      reload()
    }
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
    title = "Transactions"
    tabBarItem.image = #imageLiteral(resourceName: "transactions")
    render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard let account = AccountManager.shared.getAccounts().first else {
      return
    }
    transactions = AddressManager.shared.transactions(for: account).reversed()
  }
  
  func reload() {
    tableView.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return transactions.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = "TransactionCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ??
      UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: identifier)
    
    let transaction = transactions[indexPath.row]
    cell.textLabel?.text = transaction.amount
    cell.detailTextLabel?.text = dateFormatter.string(from: transaction.time)
    cell.backgroundColor = UIColor.fscLightGreen
    
    return cell
  }
}

//
//  TransactionsViewController.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 25/03/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

class TransactionsTableViewController: UITableViewController {
  
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
  }()
  
  var transactions: [WalletTransaction] = [] {
    didSet {
      reload()
    }
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
    title = "Transactions"
    tabBarItem.image = #imageLiteral(resourceName: "transactions")
    render()
    tableView.register(cellClass: TransactionTableViewCell.self)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func render() {
    view.backgroundColor = UIColor.white
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    transactions = NetworkManager.shared.wallet.transactions.reversed()
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
    let cell = tableView.dequeReusableCell(for: TransactionTableViewCell.self)

    let transaction = transactions[indexPath.row]
    cell.transaction = transaction
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let transaction = transactions[indexPath.row]
    let controller = TransactionViewController(transaction: transaction)
    navigationController?.pushViewController(controller, animated: true)
  }
}

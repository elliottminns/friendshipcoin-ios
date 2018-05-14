//
//  Wallet.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

class Wallet {
  
  enum Error: Swift.Error {
    case addressNotFound
  }
  
  struct Notifications {
    static let scanningStarted = Notification.Name(rawValue: "wallet.notifications.scanningStarted")
    static let scanningEnded = Notification.Name(rawValue: "wallet.notifications.scanningStarted")
  }
  
  let chain: Blockchain
  
  let scanQueue = DispatchQueue(label: "wallet.queue.scan")
  
  static let lastScannedKey: String = "wallet.lastscannedblock"
  
  var lastBlockScanned: Data = Data(count: 32)

  var balances: [String: UInt64]
  
  var accountAddresses: [Account: [String]] = [:] {
    didSet {
      accountAddresses.values.forEach { accountAddress in
        accountAddress.forEach {
          addresses.insert($0)
        }
      }
    }
  }
  
  fileprivate var addresses: Set<String>
  
  var accounts: [Account] = []
  
  var credits: [String: Set<WalletCredit>] = [:]
  
  var debits: [String: Set<WalletDebit>] = [:]
  
  var locks: Set<WalletCredit> = []
  
  var pending: Set<FSCTransaction> = []
  
  var store: WalletStore
  
  var allCredits: [WalletCredit] {
    return self.credits.reduce([]) { (result, obj) in
      let set = obj.value
      return result + set.map { $0 }
    }
  }
  
  var allDebits: [WalletDebit] {
    return self.debits.reduce([]) { (result, obj) in
      let set = obj.value
      return result + set.map { $0 }
    }
  }
  
  var transactions: [WalletTransaction] {
    let creditWT = self.allCredits.map { WalletTransaction.init(credit: $0) }
    let wtHash: [String: WalletTransaction] = creditWT.reduce([:]) { (result, transaction) -> [String: WalletTransaction] in
      var result = result
      if let wt = result[transaction.id] {
        var walletT = wt
        walletT.credits.append(contentsOf: transaction.credits)
        result[transaction.id] = walletT
      } else {
        result[transaction.id] = transaction
      }
      
      return result
    }
    
    let fullHashed: [String: WalletTransaction] = self.allDebits.reduce(wtHash) { (result, debit) -> [String: WalletTransaction] in
      var result = result
      let transaction = debit.transaction
      
      if let trans = result[transaction.id] {
        var walletT = trans
        walletT.debits.append(debit)
        result[transaction.id] = walletT
      } else {
        result[transaction.id] = WalletTransaction(debit: debit)
      }
      
      return result
    }
    
    return fullHashed.values.sorted()
  }
  
  var utxos: [WalletCredit] {
    
    let inputs = credits.reduce(Set<WalletCredit>()) { (result, item) -> Set<WalletCredit> in
      var res = result
      item.value.forEach { res.insert($0) }
      return res
    }
    
    let outputs: [String: WalletDebit] = debits.reduce([:]) { (result, item) -> [String: WalletDebit] in
      var result = result
      item.value.forEach { result["\($0.input.id)-\($0.input.index)"] = $0 }
      return result
    }
    
    let utxos = inputs.filter { (credit) -> Bool in
      guard !locks.contains(credit) else { return false }
      let id = "\(credit.transaction.id)-\(credit.outputIndex)"
      return outputs[id] == nil
    }
    
    return utxos.map {
      $0
    }
  }
  
  init(chain: Blockchain, store: WalletStore) {
    self.chain = chain
    self.balances = [:]
    self.accounts = []
    self.addresses = []
    self.store = store
    self.store.load(wallet: self)
  }
  
  func loadAccounts(_ number: Int) {
    guard number > accounts.count else { return }
    let range = accounts.count ..< number
    
    range.forEach { index in
      guard let key = try? KeyManager.shared.getPublicBase58(account: index) else { return }
      let account = Account(publicKey: key, index: index)
      accounts.append(account)
    }
  }
  
  func getAccounts() -> [Account] {
    if self.accounts.count > 0 { return self.accounts }
    guard let key = try? KeyManager.shared.getPublicBase58(account: 0) else {
      return []
    }
    let account = Account(publicKey: key, index: 0)
    accounts.append(account)
    return accounts
  }
  
  func addAccount(for key: String, index: Int, rescan: Bool = false, callback: @escaping (Account) -> Void) {
    let account = Account(publicKey: key, index: index)
    
    if accounts.count == 0 {
      self.lastBlockScanned = chain.tip.hash
    }
    
    self.accounts.append(account)
    try? self.load(addresses: 5, for: account, callback: {})
    
    if !rescan {
      self.store.save(wallet: self)
      callback(account)
    } else {
      self.lastBlockScanned = Data(count: 32)
      if !NetworkManager.shared.isSyncing {
        DispatchQueue.global().async {
          self.scanForBalances {}
        }
      }
      callback(account)
    }
  }
  
  func add(pending transaction: FSCTransaction) {
    pending.insert(transaction)
  }
  
  func lock(utxos: [WalletCredit]) {
    utxos.forEach { self.locks.insert($0) }
  }
  
  func balance(for account: Account) -> String {
    let _ = self.transactions
    let addresses = self.accountAddresses[account] ?? []
    
    let creditAmount = addresses.reduce(0) { (result, address) -> Int64 in
      let income = self.credits[address]?.reduce(0, { (res, cred) -> UInt64 in
//        guard !locks.contains(cred) else { return res }
        return res + cred.amount
      }) ?? 0
      
      let outgoings = self.debits[address]?.reduce(0, { (res, debit) -> UInt64 in
        return res + debit.amount
      }) ?? 0
      
      return Int64(income) - Int64(outgoings) + result
    }
    
    let pendingResults = self.pending.map(self.check(transaction:))
    let pendingCredits = pendingResults.flatMap { $0.credits }
    let prendingDebits = pendingResults.flatMap { $0.debits }
    let pendingIncome = pendingCredits.amount
    let pendingOutcome = prendingDebits.amount

    let pendingAdjust = Int64(pendingIncome) - Int64(pendingOutcome)
    let total = creditAmount + pendingAdjust

    return "\(Double(total) * 1e-8) FSC"
  }
  
  func load(addresses number: Int, for account: Account, callback: @escaping () -> Void) throws {
    let count = (self.accountAddresses[account] ?? []).count
    
    let node = try HDNode(base58: account.publicKey,
                          network: NetworkType.friendshipcoin)
    
    let range = count ..< (number + count)
    let addresses = range.compactMap { (index) -> String? in
      guard let value = try? node.derive(0).derive(index).address else {
        return nil
      }
      return value
    }
    
    let pre = self.accountAddresses[account] ?? []
    self.accountAddresses[account] = pre + addresses
    
    DispatchQueue.global().async {
      self.store.save(wallet: self)
      callback()
    }

  }
  
  func index(of address: String, in account: Account) throws -> Int {
    guard let index = self.accountAddresses[account]?.index(of: address) else {
      throw Error.addressNotFound
    }
    return index
  }
  
  func unusedAddress(for account: Account) -> String {
    let addresses = self.accountAddresses[account] ?? []
    
    let unused = addresses.filter { address in
      let credits = self.credits[address] ?? []
      return credits.count == 0
    }
    
    if unused.count < 25 {
      DispatchQueue.global().async {
        do {
          try self.load(addresses: 250, for: account) {}
        } catch {}
      }
    }
    
    return unused.first ?? ""
  }

  func scanForBalances(callback: @escaping () -> Void) {
    scanQueue.async {
      let tip = self.chain.tip
      guard let top = self.chain.block(with: tip.hash) else { return }
      
      if self.accounts.count == 0 {
        self.lastBlockScanned = tip.hash
      }
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: Notifications.scanningStarted, object: nil)
      }
      
      var current: FSCBlock? = top
      var wasANull: Bool = false
      
      var credits: [WalletCredit] = []
      var debits: [WalletDebit] = []
      
      while let block = current, block.hash != self.lastBlockScanned, block.hash != self.chain.genesis.hash {
        
        let results = block.transactions.map { self.check(transaction: $0) }
        credits.append(contentsOf: results.flatMap { $0.credits })
        debits.append(contentsOf: results.flatMap { $0.debits })
        
        current = self.chain.block(with: block.previousHash)
        if (current == nil ) {
          wasANull = true
        }
      }
      
      credits.forEach(self.add(credit:))
      debits.forEach(self.add(debit:))
      
      if !wasANull {
        self.lastBlockScanned = top.hash
      }
      
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: Notifications.scanningEnded, object: nil, userInfo: [
          "credits": credits,
          "debits": debits
        ])
        callback()
        self.store.save(wallet: self)
      }
    }
  }
  
  func check(transaction: FSCTransaction) -> (credits: [WalletCredit], debits: [WalletDebit]) {
    var debits: [WalletDebit] = []
    var credits: [WalletCredit] = []
    
    pending.remove(transaction)
    
    transaction.outputs.enumerated().forEach { item in
      let output = item.element
      guard let address = output.address(network: NetworkType.friendshipcoin) else {
        return
      }
      
      if self.addresses.contains(address.address) {
        let credit = WalletCredit(transaction: transaction,
                                  outputIndex: item.offset,
                                  address: address.address)
        
        credits.append(credit)
      }
    }
    
    transaction.inputs.enumerated().forEach { item in
      let input = item.element
      guard let address = input.address(network: NetworkType.friendshipcoin) else {
        return
      }
      
      if self.addresses.contains(address.address) {
        let debit = WalletDebit(transaction: transaction,
                                inputIndex: item.offset,
                                address: address.address)

        debits.append(debit)
      }
    }
    
    return (credits: credits, debits: debits)
  }
  
  fileprivate func add(credit: WalletCredit) {
    var original = self.credits[credit.address] ?? []
    original.insert(credit)
    self.credits[credit.address] = original
  }
  
  fileprivate func add(debit: WalletDebit) {
    var original = self.debits[debit.address] ?? []
    original.insert(debit)
    self.debits[debit.address] = original
  }
}

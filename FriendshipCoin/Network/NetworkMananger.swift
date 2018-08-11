//
//  NetworkMananger.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

struct Coin {
  static let modifier: Double = 1e8
}

class NetworkManager {
  
  struct Notifications {
    static let isSyncingStarted = Notification.Name("NetworkManager.Notifications.isSyncingStarted")
    static let isSyncingStopped = Notification.Name("NetworkManager.Notifications.isSyncingStopped")
    static let syncMessage = Notification.Name("NetworkManager.Notifications.syncMessage")
    static let syncDetailMessage = Notification.Name("NetworkManager.Notifications.syncDetailMessage")
    static let incomingTransaction = Notification.Name("NetworkManager.Notifications.incomingTransaction")
  }
  
  static let shared: NetworkManager = NetworkManager()
  
  let network: P2PNetwork<FSCBlock>
  
  let blockchain: Blockchain
  
  let connectingGroup = DispatchGroup()
  
  var synced: Bool = false
  
  let spacing: TimeInterval = 60
  
  let wallet: Wallet
  
  var headers: [BlockHeader] = []
  
  var transactions: Set<Data> = []
  
  let syncTask: SyncTask
  
  var inventoryQueue: [Data] = []
  
  var syncMessage: String? {
    didSet {
      guard let message = syncMessage, message != oldValue else { return }
      
      let name = Notifications.syncMessage
      
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: name, object: self, userInfo: [
          "message": message
          ])
      }
    }
  }
  
  var syncDetailMessage: String? {
    didSet {
      guard let message = syncDetailMessage, message != oldValue else { return }
      
      let name = Notifications.syncDetailMessage
      
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: name, object: self, userInfo: [
          "message": message
          ])
      }
    }
  }
  
  fileprivate(set) var isSyncing: Bool = true {
    didSet {
      guard isSyncing != oldValue else { return }
      
      let name = isSyncing ? Notifications.isSyncingStarted : Notifications.isSyncingStopped
      
      if !isSyncing {
        NotificationCenter.default.post(name: name, object: self)
        self.syncMessage = "Loading balances..."
        self.syncDetailMessage = ""
        self.wallet.scanForBalances {}
      } else {
        NotificationCenter.default.post(name: name, object: self)
      }
    }
  }
  
  var inventoryDict: [Data: Int] = [:]
  
  var inventoryHashes: [Data] = []
  
  fileprivate var hasConnected: Bool = false {
    didSet {
      if hasConnected && !oldValue {
        connectingGroup.leave()
      } else if !hasConnected && oldValue {
        connectingGroup.enter()
      }
    }
  }
  
  var isConnected: Bool {
    return network.peers.count > 0
  }
  
  var connectionCount: Int {
    return network.peers.count
  }
  
  var blocksToDownload: [Data] = []
  
  let magic: Magic = 0xdeb1c311
  
  var checkTimer: Timer?
  
  init() {
    let defaultPort: UInt32 = 58008
    let nodes = ["54.172.62.103", "167.99.13.126", "104.131.176.130",
                 "45.55.37.221", "98.100.196.184", "85.25.33.25",
                 "199.247.7.70", "217.182.253.139", "45.77.74.59",
                 "188.138.61.146", "207.246.103.231", "52.90.5.72",
                 "98.100.196.185", "37.9.231.144", "18.205.205.207",
                 "144.202.13.250", "62.75.152.56", "163.172.210.80"]
    let dns = ["node.friendshipcoin.com"]
    let params = P2PNetwork<FSCBlock>.Parameters(magic: magic,
                                       defaultPort: defaultPort,
                                       dnsSeeds: dns,
                                       staticNodes: nodes)
    blockchain = Blockchain()
    network = P2PNetwork(parameters: params)
    wallet = Wallet(chain: blockchain, store: WalletStore())
    syncTask = SyncTask(blockchain: blockchain, network: network, magic: magic)
    network.delegate = self
    connectingGroup.enter()
    self.load()
  }
  
  func load() {
    network.add(messageHandler: self)
    isSyncing = true
    syncTask.start(progressDelegate: self) {
      self.isSyncing = false
      self.download(blocks: self.inventoryHashes)
    }
  }
  
  func broadcast(transaction: FSCTransaction) {
    network.waitForConnection {
      self.network.broadcast(transaction: transaction)
    }
  }
  
  func connect() {
    network.connect()
  }
  
  func download(blocks hashes: [Data]) {
    guard !syncTask.isSyncing,
      hashes.count > 0 else { return }
    
    self.network.get(blocks: hashes) { (result) in
      switch result {
      case .success(let blocks):
        guard blocks.count > 0 else { return }
        self.blockchain.add(blocks: blocks)
        self.wallet.scanForBalances {
          
        }
      case .failure(_):
        break
      }
    }
  }
  
  func addInventory(hash: Data) {
    guard !syncTask.isSyncing else {
      self.inventoryHashes.append(hash)
      return
    }
    waitForConnection {
      self.download(blocks: [hash])
    }
  }
  
  
  func waitForConnection(callback: @escaping () -> Void) {
    guard !isConnected else { return callback() }
    connectingGroup.notify(queue: DispatchQueue.main) {
      callback()
    }
  }
}

extension NetworkManager: P2PNetworkDelegate {
  func network<T>(_ network: P2PNetwork<T>, didConnectToPeer peer: Peer) {
    hasConnected = true
  }
  
  func network<T>(_ network: P2PNetwork<T>, didDisconnectFromPeer peer: Peer) {
    if connectionCount == 0 {
      hasConnected = false
    }
  }
  
}

extension NetworkManager: SyncTaskProgressDelegate {
  func sync(task: SyncTask, didUpdateProgress progress: Progress, ofType type: SyncTask.SyncType) {
    switch type {
    case .blocks:
      syncMessage = "Downloading blocks..."
      if progress.totalUnitCount > 0 {
        syncDetailMessage = "\(progress.completedUnitCount) / \(progress.totalUnitCount)"
      } else {
        syncDetailMessage = ""
      }
    case .file:
      syncMessage = "Loading block data..."
      let completed = String.init(format: "%.2f", progress.fractionCompleted * 100)
      syncDetailMessage = "\(completed)%"
    case .headers:
      syncMessage = "Obtaining headers..."
      if progress.totalUnitCount > 4 {
        syncDetailMessage = "\(progress.completedUnitCount) / \(progress.totalUnitCount)"
      } else {
        syncDetailMessage = ""
      }
    case .none:
      syncMessage = ""
      syncDetailMessage = ""
    }
  }
}

extension NetworkManager: MessageHandler {
  var isFinished: Bool {
    return false
  }
  
  func handle(message: Message, from peer: Peer) {
    do {
      let reader = DataReader(data: message.value)
      let _: UInt8 = try reader.read(endian: .little)
      let type: UInt32 = try reader.read(endian: .little)
      if type == 2 {
        let hash = try reader.read(bytes: 32)
        self.inventoryDict[hash] = (self.inventoryDict[hash] ?? 0) + 1
        if self.inventoryDict[hash] == network.peers.count / 2 {
          self.addInventory(hash: hash)
        }
      } else if type == 1 {
        let hash = try reader.read(bytes: 32)
        guard !transactions.contains(hash) else { return }

        network.get(transactions: [hash], peer: peer) { (result) in
          DispatchQueue.main.async {
            guard !self.transactions.contains(hash) else { return }
            self.transactions.insert(hash)
            if case let .success(txs) = result {
              let results = txs.map(self.wallet.check(transaction:))
              let credits = results.flatMap { $0.credits }
              let debits = results.flatMap { $0.debits }
              
              let total = Int64(credits.amount) - Int64(debits.amount)
              
              if total > 0 {
                NotificationCenter.default.post(name: Notifications.incomingTransaction, object: nil, userInfo: [
                  "transactions": txs,
                  "amount": total
                  ])
              }
            }
          }
        }
      }
    } catch _ {}
  }
  
  func handles(message: Message) -> Bool {
    return message.type == "inv"
  }
  
  func depth(of blockHash: Data, max: Int) -> Int {
    var count = 1
    
    var current: FSCBlock? = blockchain.tip
    
    while let curr = current, curr.hash != blockHash, count < max {
      count = count + 1
      current = blockchain.block(with: curr.previousHash)
    }
    
    return count
  }
}

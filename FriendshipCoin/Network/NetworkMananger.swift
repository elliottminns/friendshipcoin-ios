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
  }
  
  static let shared: NetworkManager = NetworkManager()
  
  let network: P2PNetwork<FSCBlock>
  
  let blockchain: Blockchain
  
  let connectingGroup = DispatchGroup()
  
  var synced: Bool = false
  
  let spacing: TimeInterval = 60
  
  let wallet: Wallet
  
  var headers: [BlockHeader] = []
  
  let syncTask: SyncTask
  
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
        self.wallet.scanForBalances {
          
        }
      } else {
        NotificationCenter.default.post(name: name, object: self)
      }
      
      if checkTimer == nil {
        checkTimer = Timer.scheduledTimer(withTimeInterval: spacing, repeats: true, block: { _ in
//          self.downloadHeaders()
        })
      }
    }
  }
  
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
//    let nodes = ["54.172.62.103", "167.99.13.126", "104.131.176.130", "45.55.37.221"]
//    let dns = ["node.friendshipcoin.com"]
    let dns: [String] = []
//    let nodes = ["167.99.13.126"]
    let nodes = ["127.0.0.1"]
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
    self.isSyncing = true
    syncTask.start(progressDelegate: self) {
      self.isSyncing = false
    }
  }
  
  func loadMissingBlocks() {
    self.syncMessage = "Scanning blocks..."
    self.blockchain.missingBlocks { (headers) in
      self.blocksToDownload = headers.map { $0.hash }
      self.downloadHeaders()
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
  
  func downloadHeaders() {
    self.isSyncing = true
    waitForConnection {
      self.syncMessage = "Downloading headers..."
      let tip = self.blockchain.tip
      let locator = self.headers.last?.hash ?? tip.hash
      let previous = self.headers.last?.prevHash ?? tip.prevHash
      let locators = [locator, previous]
      print("GET HEADERS WITH LOCATOR: \(locator.hexEncodedString())")
      self.network.getHeaders(locators: locators, stop: nil) { result in
        self.onHeaders(result)
      }
    }
  }
  
  func download(blocks headers: [BlockHeader]) {
    download(blocks: headers.map { $0.hash })
  }
  
  func download(blocks hashes: [Data]) {
    self.isSyncing = true
    
    guard hashes.count > 0 else {
      self.isSyncing = false
      return
    }
    
    waitForConnection {
      self.syncMessage = "Downloading blocks..."
      var blockHashes = hashes
      let part = (0 ..< 500).compactMap({ (item) -> Data? in
        guard blockHashes.count > 0 else { return nil }
        return blockHashes.removeFirst()
      })

      self.network.get(blocks: part) { result in
        if case let .success(blocks) = result {
          do {
            try self.blockchain.add(blocks: blocks)
            self.download(blocks: blockHashes)
          } catch _ {
            print("Broken chain shit again")
          }
        } else {
          self.download(blocks: hashes)
        }
      }
    }
  }
  
  func onHeaders(_ result: CoinKit.Result<[BlockHeader]>) {
    switch result {
    case .success(let headers):
        self.add(headers: headers)
        if headers.count > 0 {
          self.downloadHeaders()
        } else {
          self.download(blocks: self.headers.map { $0.hash })
          //            self.headers.removeAll()
        }
    case .failure(_): break
    }
  }
  
  func add(headers: [BlockHeader]) {
    
    var last = self.headers.last ?? self.blockchain.tip
    
    let filtered = headers.filter { header -> Bool in
      if last.hash == header.prevHash {
        last = header
        return true
      } else {
        return false
      }
    }
    
    self.headers.append(contentsOf: filtered)
  }
  
  func onInventory(_ result: CoinKit.Result<[Data]>) {
    DispatchQueue.main.async {
      switch result {
      case .success(let hashes):
        self.blocksToDownload.append(contentsOf: hashes)
        if hashes.count > 0 {
//          self.downloadBlockHashes()
//          self.download(blocks: hashes)
        } else {
          //self.download(blocks: self.blocksToDownload)
          //self.blocksToDownload.removeAll()
        }
      case .failure(_): break
      }
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
      syncDetailMessage = "\(progress.completedUnitCount) / \(progress.totalUnitCount)"
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

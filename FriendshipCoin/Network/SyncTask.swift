//
//  SyncTask.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 30/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

protocol SyncTaskProgressDelegate {
  func sync(task: SyncTask, didUpdateProgress progress: Progress, ofType type: SyncTask.SyncType)
}

class SyncTask {
  
  enum Error: Swift.Error {
    case noFileFound
  }
  
  enum SyncType {
    case none
    case file
    case headers
    case blocks
  }
  
  fileprivate(set) var progress: Progress
  
  fileprivate let blockchain: Blockchain
  
  fileprivate let network: P2PNetwork<FSCBlock>
  
  fileprivate let magic: Magic
  
  fileprivate var headers: [BlockHeader] = []
  
  fileprivate var callback: (() -> Void)?
  
  fileprivate(set) var isSyncing: Bool = false
  
  fileprivate var syncProgressDelegate: SyncTaskProgressDelegate?
  
  fileprivate var observer: NSKeyValueObservation?
  
  fileprivate var state: SyncType
  
  fileprivate var hasLoadedInitial: Bool {
    get {
      return UserDefaults.standard.bool(forKey: "hasLoadedInitial")
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: "hasLoadedInitial")
      UserDefaults.standard.synchronize()
    }
  }
  
  init(blockchain: Blockchain, network: P2PNetwork<FSCBlock>, magic: Magic) {
    self.progress = Progress(totalUnitCount: -1)
    self.network = network
    self.magic = magic
    self.blockchain = blockchain
    self.state = .none
  }
  
  func start(progressDelegate: SyncTaskProgressDelegate, callback: @escaping () -> Void) {
    guard !isSyncing else { return }
    self.syncProgressDelegate = progressDelegate
    self.progress = Progress(totalUnitCount: 4)
    self.headers = []
    isSyncing = true
    self.callback = callback
    
    DispatchQueue.global().async {
      if !self.hasLoadedInitial {
        self.loadFileChain()
      } else {
        self.downloadHeaders()
      }
    }
    progress.becomeCurrent(withPendingUnitCount: 0)
  }
  
  fileprivate func loadFileChain() {
    do {
      self.state = .file
      let bundle = Bundle.main
      guard let fileUrl = bundle.url(forResource: "blk0001", withExtension: "dat") else {
        throw Error.noFileFound
      }
      let filechain = FileChain(fileUrl: fileUrl, blockchain: self.blockchain, magic: self.magic)
      
      let fileProgress = try filechain.loadChain {
        self.progress = Progress(totalUnitCount: Int64(self.headers.count))
        self.progress.becomeCurrent(withPendingUnitCount: Int64(self.headers.count))
        self.hasLoadedInitial = true
        self.downloadHeaders()
      }
      self.progress.addChild(fileProgress, withPendingUnitCount: 2)
      
      fileProgress.becomeCurrent(withPendingUnitCount: 1)
      self.observer = fileProgress.observe(\.fractionCompleted) { (progress, change) in
        self.syncProgressDelegate?.sync(task: self, didUpdateProgress: progress, ofType: .file)
      }
      
    } catch _ {
      self.progress = Progress(totalUnitCount: Int64(self.headers.count))
      self.progress.becomeCurrent(withPendingUnitCount: Int64(self.headers.count))
      downloadHeaders()
    }
  }
  
  fileprivate func downloadHeaders() {
    self.state = .headers
    self.headerLoop()
  }
  
  fileprivate func headerLoop() {
    guard state == .headers else { return }
    network.waitForConnection {
      let tip = self.blockchain.tip
      let locator = self.headers.last?.hash ?? tip.hash
      let previous = self.headers.last?.prevHash ?? tip.prevHash
      let locators = [locator, previous]
      
      self.syncProgressDelegate?.sync(task: self, didUpdateProgress: self.progress, ofType: .headers)
      
      self.network.getHeaders(locators: locators, stop: nil) { result in
        guard self.state == .headers else { return }
        switch result {
        case .success(let headers):
          self.add(headers: headers)
          self.progress.totalUnitCount = Int64(self.headers.count)
          self.syncProgressDelegate?.sync(task: self, didUpdateProgress: self.progress, ofType: .headers)
          if headers.count > 0 {
            self.headerLoop()
          } else {
            self.download(blocks: self.headers.map { $0.hash })
          }
        case .failure(_): break
        }
      }
    }
  }
  
  fileprivate func download(blocks hashes: [Data]) {
    state = .blocks
    blockLoop(hashes: hashes)
  }
  fileprivate func blockLoop(hashes: [Data]) {
    guard state == .blocks else { return }
    
    self.syncProgressDelegate?.sync(task: self, didUpdateProgress: self.progress, ofType: .blocks)
    guard hashes.count > 0 else {
      self.isSyncing = false
      self.state = .none
      self.callback?()
      return
    }
    network.waitForConnection {
      var blockHashes = hashes
      let part = (0 ..< 500).compactMap({ (item) -> Data? in
        guard blockHashes.count > 0 else { return nil }
        return blockHashes.removeFirst()
      })
      
      self.network.get(blocks: part) { result in
        guard self.state == .blocks else { return }
        if case let .success(blocks) = result {
          do {
            try self.blockchain.add(blocks: blocks)
            self.progress.completedUnitCount = self.progress.completedUnitCount + Int64(blocks.count)
            self.syncProgressDelegate?.sync(task: self, didUpdateProgress: self.progress, ofType: .blocks)
            self.blockLoop(hashes: blockHashes)
          } catch _ {
            print("Broken chain shit again")
            self.blockLoop(hashes: hashes)
          }
        } else {
          self.blockLoop(hashes: hashes)
        }
      }
    }
  }
  
  fileprivate func add(headers: [BlockHeader]) {
    
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
  
}

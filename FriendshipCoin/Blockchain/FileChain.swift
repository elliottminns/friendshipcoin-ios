//
//  FileChain.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 27/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import Foundation
import CoinKit

class FileChain {
  
  let fileUrl: URL
  
  let blockchain: Blockchain
  
  let magic: Magic
  
  init(fileUrl: URL, blockchain: Blockchain, magic: Magic) {
    self.fileUrl = fileUrl
    self.blockchain = blockchain
    self.magic = magic
  }
  
  func loadChain(callback: @escaping () -> Void) throws -> Progress {
    let fileData = try Data(contentsOf: fileUrl)
    let progress = Progress(totalUnitCount: Int64(fileData.count))
    DispatchQueue.global().async {
      let reader = DataReader(data: fileData)
      repeat {
        guard let magicBytes: Magic = try? reader.read(endian: .little),
          let size: UInt32 = try? reader.read(endian: .little),
          magicBytes == self.magic,
          let blockData = try? reader.read(bytes: UInt(size)),
          let block = try? FSCBlock(data: blockData) else { continue }
        
        self.blockchain.add(block: block)
        DispatchQueue.main.async {
          progress.completedUnitCount = progress.completedUnitCount + Int64(size)
        }
      }  while !reader.isEnded
 
      DispatchQueue.main.async {
        callback()
      }
    }
    
    return progress
  }
}

//
//  Blockchain.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 24/04/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

//import Foundation
import CoinKit

class Blockchain: CoinKit.Blockchain<FSCBlock> {
  init() {
    /*
    let merkleR = "73493cadda0b9042bae383208bccc06c47c46892ba8feea5d831d358eb1626d4".hexadecimal() ?? Data()
    let reversed = merkleR.reversed()
    let merkle = Data(reversed)
    let prevHash = Data(bytes: [UInt8](repeating: 0, count: 32))
    let genesisHeader = BlockHeader(version: 1, prevHash: prevHash,
                                    merkleRoot: merkle, bits: 0x1e0fffff,
                                    nonce: 587523, timestamp: 1519845939,
                                    transactionCount: 0, hashingAlgorithm: NeoScrypt())*/
    
    let genesisData = "010000000000000000000000000000000000000000000000000000000000000000000000D42616EB58D331D8A5EE8FBA9268C4476CC0CC8B2083E3BA42900BDAAD3C49733302975AFFFF0F1E03F708000101000000B044745A010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF1E00012A1A497427732074696D6520746F2067657420667269656E646C7921FFFFFFFF010000000000000000000000000000".hexadecimal()!
    let genesis = try! FSCBlock(data: genesisData)
    super.init(genesis: genesis, hashingAlgorithm: NeoScrypt())
  }
}

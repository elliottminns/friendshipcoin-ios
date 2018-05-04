//
//  ReusableCell.swift
//  FriendshipCoin
//
//  Created by Elliott Minns on 01/05/2018.
//  Copyright © 2018 FriendshipCoin. All rights reserved.
//

import UIKit

public protocol ReusableCell: class {}

public extension ReusableCell where Self: UITableViewCell {
  public static var reusableIdentifier: String { return String(describing: self) }
}

public extension ReusableCell where Self: UICollectionViewCell {
  public static var reusableIdentifier: String { return String(describing: self) }
}

public extension UITableView {
  public func register<T: ReusableCell>(cellClass: T.Type) where T: UITableViewCell {
    self.register(cellClass, forCellReuseIdentifier: cellClass.reusableIdentifier)
  }
  
  public func dequeReusableCell<T: ReusableCell>(for classType: T.Type) -> T where T: UITableViewCell {
    return self.dequeueReusableCell(withIdentifier: classType.reusableIdentifier) as! T
  }
  
  public func dequeReusableCell<T: ReusableCell>(for classType: T.Type, for indexPath: IndexPath) -> T where T: UITableViewCell {
    return self.dequeueReusableCell(withIdentifier: classType.reusableIdentifier, for: indexPath) as! T
  }
}

//
//  Node.swift
//  Flix
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public protocol _Node {
    
    var providerIdentity: String { get }
    
    func _unwarp<Value>() -> Value
    
    var providerStartIndexPath: IndexPath { get set }
    var providerEndIndexPath: IndexPath { get set }
    
}

public struct Node: _Node {
    
    public let providerIdentity: String
    public let value: Any
    
    public var providerStartIndexPath = IndexPath(row: 0, section: 0)
    public var providerEndIndexPath = IndexPath(row: 0, section: 0)
    
    init(providerIdentity: String, value: Any) {
        self.providerIdentity = providerIdentity
        self.value = value
    }
    
    public func _unwarp<Value>() -> Value {
        return self.value as! Value
    }

}

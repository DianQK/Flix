//
//  IdentifiableNode.swift
//  Flix
//
//  Created by DianQK on 22/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxDataSources

public protocol StringIdentifiableType {
    
    var identity: String { get }
    
}

extension Equatable {
    
    fileprivate func isEqual(value: Self) -> Bool {
        return self == value
    }
    
}

public struct IdentifiableNode: _Node, IdentifiableType, Equatable {
    
    public static func ==(lhs: IdentifiableNode, rhs: IdentifiableNode) -> Bool {
        return lhs.isEqual(rhs.value)
    }
    
    public var identity: String {
        return providerIdentity + value.identity
    }
    
    public let providerIdentity: String
    
    public typealias Identity = String
    
    public let value: StringIdentifiableType
    public let isEqual: (StringIdentifiableType) -> (Bool)
    
    public var providerStartIndexPath = IndexPath(row: 0, section: 0)
    public var providerEndIndexPath = IndexPath(row: 0, section: 0)
    
    public init<T: StringIdentifiableType & Equatable>(providerIdentity: String, valueNode: T) {
        self.providerIdentity = providerIdentity
        self.value = valueNode
        let isEqual = valueNode.isEqual
        self.isEqual = { value in
            isEqual(value as! T)
        }
    }
    
    public func _unwarp<Value>() -> Value {
        return self.value as! Value
    }
    
}


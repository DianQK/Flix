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

public protocol StringIdentifiableType {
    var identity: String { get }
}

extension Equatable {
    
    fileprivate func isEqual(value: Self) -> Bool {
        return self == value
    }
    
}

public struct IdentifiableNode: IdentifiableType, Equatable {
    
    public static func ==(lhs: IdentifiableNode, rhs: IdentifiableNode) -> Bool {
        return lhs.isEqual(rhs.node)
    }
    
    public var identity: String {
        return node.identity
    }

    public typealias Identity = String
    
    public let node: StringIdentifiableType & _Node
    public let isEqual: (StringIdentifiableType & _Node) -> (Bool)
    
    public init<T: StringIdentifiableType & Equatable & _Node>(node: T) {
        self.node = node
        let isEqual = node.isEqual
        self.isEqual = { value in
            isEqual(value as! T)
        }
    }
    
}

struct ValueNode<V>: Node {
    
    let providerIdentity: String
    let value: V
    
}

public struct IdentifiableValueNode<V: Equatable & StringIdentifiableType>: Node, Equatable, StringIdentifiableType {
    
    public var identity: String {
        return value.identity
    }
    
    public static func ==(lhs: IdentifiableValueNode<V>, rhs: IdentifiableValueNode<V>) -> Bool {
        return lhs.value == rhs.value
    }
    
    public let providerIdentity: String
    public let value: V
    
    public init(providerIdentity: String, value: V) {
        self.providerIdentity = providerIdentity
        self.value = value
    }
    
}

public protocol _Node {
    
    var providerIdentity: String { get }
    
}

public protocol Node: _Node {
    
}

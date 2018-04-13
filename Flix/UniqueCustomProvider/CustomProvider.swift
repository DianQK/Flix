//
//  CustomProvider.swift
//  Flix
//
//  Created by DianQK on 2018/4/13.
//  Copyright © 2018 DianQK. All rights reserved.
//

import Foundation

public protocol CustomProvider: class {

    associatedtype Cell: NSObject

    func whenGetCell(_ cellConfig: @escaping (Cell) -> ())

}

private var cellQueuesKey: Void?
private var cellKey: Void?

extension CustomProvider {

    public var cell: Cell? {
        get {
            return objc_getAssociatedObject(self, &cellKey) as? Cell
        }
        set {
            objc_setAssociatedObject(self, &cellKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private var configCellQueues: [(Cell) -> ()] {
        get {
            return (objc_getAssociatedObject(self, &cellQueuesKey) as? [(Cell) -> ()]) ?? []
        }
        set {
            objc_setAssociatedObject(self, &cellQueuesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func whenGetCell(_ cellConfig: @escaping (Cell) -> ()) {
        if let cell = self.cell {
            cellConfig(cell)
        } else {
            configCellQueues.append(cellConfig)
        }
    }

    func onGetCell(_ cell: Cell) {
        self.cell = cell
        for config in configCellQueues {
            config(cell)
        }
        configCellQueues.removeAll()
    }

}

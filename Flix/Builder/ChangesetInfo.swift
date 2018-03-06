//
//  ChangesetInfo.swift
//  Flix
//
//  Created by DianQK on 06/03/2018.
//  Copyright © 2018 DianQK. All rights reserved.
//

import Foundation
import RxDataSources

public protocol ChangesetInfo {

    var reloadData: Bool { get }

    var insertedSections: [Int] { get }
    var deletedSections: [Int] { get }
    var movedSections: [(from: Int, to: Int)] { get }
    var updatedSections: [Int] { get }

    var insertedItems: [ItemPath] { get }
    var deletedItems: [ItemPath] { get }
    var movedItems: [(from: ItemPath, to: ItemPath)] { get }
    var updatedItems: [ItemPath] { get }

}

extension Changeset: ChangesetInfo { }

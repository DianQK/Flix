//
//  TableViewBuilderMemoryLeakTests.swift
//  FlixTests
//
//  Created by DianQK on 2018/4/13.
//  Copyright © 2018 DianQK. All rights reserved.
//

import XCTest
import Flix

class TableViewBuilderMemoryLeakTests: XCTestCase {

    func testTableBuilderMemoryLeak() {
        var tableView: UITableView? = UITableView(frame: .zero, style: .grouped)
        weak var builder: TableViewBuilder? = TableViewBuilder(tableView: tableView!, providers: [SingleUITableViewCellProvider()])
        tableView = nil
        XCTAssertNil(tableView)
        XCTAssertNil(builder)
    }

    func testAnimatableTableViewBuilderMemoryLeak() {
        var tableView: UITableView? = UITableView(frame: .zero, style: .grouped)
        weak var builder: AnimatableTableViewBuilder? = AnimatableTableViewBuilder(tableView: tableView!, providers: [SingleUITableViewCellProvider()])
        tableView = nil
        XCTAssertNil(tableView)
        XCTAssertNil(builder)
    }

}

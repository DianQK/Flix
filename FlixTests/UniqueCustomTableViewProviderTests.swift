//
//  UniqueCustomTableViewProviderTests.swift
//  FlixTests
//
//  Created by DianQK on 2018/4/13.
//  Copyright © 2018 DianQK. All rights reserved.
//

import XCTest
@testable import Flix

class UniqueCustomTableViewProviderTests: XCTestCase {

    func testWhenGetCellMemoryLeak() {
        var tableView: UITableView? = UITableView(frame: .zero, style: .grouped)
        var provider: UniqueCustomTableViewProvider? = UniqueCustomTableViewProvider()
        weak var weakProvider = provider
        provider!.selectionStyle = .none
        weak var builder: AnimatableTableViewBuilder? = AnimatableTableViewBuilder(tableView: tableView!, providers: [provider!])
        tableView = nil
        provider = nil
        XCTAssertNil(tableView)
        XCTAssertNil(builder)
        XCTAssertNil(provider)
        XCTAssertNil(weakProvider)
    }

}

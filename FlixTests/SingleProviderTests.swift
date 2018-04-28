//
//  SingleProviderTests.swift
//  FlixTests
//
//  Created by DianQK on 2018/4/13.
//  Copyright © 2018 DianQK. All rights reserved.
//

import XCTest
@testable import Flix

class SingleProviderTests: XCTestCase {

    func testTableViewWhenGetCellMemoryLeak() {
        var tableView: UITableView? = UITableView(frame: .zero, style: .grouped)
        var provider: SingleUITableViewCellProvider? = SingleUITableViewCellProvider()
        weak var weakProvider = provider
        provider!.selectionStyle = .none
        provider!.accessoryType = .checkmark
        provider!.accessoryView = UIView()
        provider!.backgroundView = UIView()
        provider!.editingAccessoryType = .checkmark
        provider!.editingAccessoryView = UIView()
        provider!.whenGetCell { (cell) in
            cell.textLabel?.text = "Flix"
        }
        weak var builder: AnimatableTableViewBuilder? = AnimatableTableViewBuilder(tableView: tableView!, providers: [provider!])
        tableView = nil
        provider = nil
        let expectation = self.expectation(description: "wait for provider disposed")
        DispatchQueue.main.async {
            XCTAssertNil(tableView)
            XCTAssertNil(builder)
            XCTAssertNil(provider)
            XCTAssertNil(weakProvider)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testCollectionViewWhenGetCellMemoryLeak() {
        var collectionView: UICollectionView? = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        var provider: SingleUICollectionViewCellProvider? = SingleUICollectionViewCellProvider()
        weak var weakProvider = provider
        weak var builder: AnimatableCollectionViewBuilder? = AnimatableCollectionViewBuilder(collectionView: collectionView!, providers: [provider!])
        provider!.backgroundView = UIView()
        provider!.selectedBackgroundView = UIView()
        collectionView = nil
        provider = nil
        let expectation = self.expectation(description: "wait for provider disposed")
        DispatchQueue.main.async {
            XCTAssertNil(collectionView)
            XCTAssertNil(builder)
            XCTAssertNil(provider)
            XCTAssertNil(weakProvider)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
    }

}

//
//  CollectionViewBuilderMemoryLeakTests.swift
//  FlixTests
//
//  Created by DianQK on 2018/4/13.
//  Copyright © 2018 DianQK. All rights reserved.
//

import XCTest
import Flix

class CollectionViewBuilderMemoryLeakTests: XCTestCase {

    func testCollectionViewBuilderMemoryLeak() {
        var collectionView: UICollectionView? = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        weak var builder: CollectionViewBuilder? = CollectionViewBuilder(collectionView: collectionView!, providers: [SingleUICollectionViewCellProvider()])
        collectionView = nil
        XCTAssertNil(collectionView)
        XCTAssertNil(builder)
    }

    func testAnimatableCollectionViewBuilderMemoryLeak() {
        var collectionView: UICollectionView? = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        weak var builder: AnimatableCollectionViewBuilder? = AnimatableCollectionViewBuilder(collectionView: collectionView!, providers: [SingleUICollectionViewCellProvider()])
        collectionView = nil
        XCTAssertNil(collectionView)
        XCTAssertNil(builder)
    }

}

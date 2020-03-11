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
    
    weak var collectionViewBuilder: CollectionViewBuilder?
    weak var animatableCollectionViewBuilder: AnimatableCollectionViewBuilder?
    
    override func setUp() {
        collectionViewBuilder = nil
        animatableCollectionViewBuilder = nil
    }

    func testCollectionViewBuilderMemoryLeak() {
        var collectionView: UICollectionView? = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        var builder: CollectionViewBuilder? = CollectionViewBuilder(collectionView: collectionView!, providers: [SingleUICollectionViewCellProvider()])
        collectionViewBuilder = builder
        builder = nil
        collectionView = nil
        XCTAssertNil(collectionView)
        XCTAssertNil(collectionViewBuilder)
    }

    func testAnimatableCollectionViewBuilderMemoryLeak() {
        var collectionView: UICollectionView? = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        var builder: AnimatableCollectionViewBuilder? = AnimatableCollectionViewBuilder(collectionView: collectionView!, providers: [SingleUICollectionViewCellProvider()])
        animatableCollectionViewBuilder = builder
        builder = nil
        collectionView = nil
        XCTAssertNil(collectionView)
        XCTAssertNil(animatableCollectionViewBuilder)
    }

}

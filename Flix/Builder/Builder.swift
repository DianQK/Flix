//
//  Builder.swift
//  Flix
//
//  Created by DianQK on 2018/4/15.
//  Copyright © 2018 DianQK. All rights reserved.
//

import RxDataSources

public protocol Builder: class {

}


protocol CombineSectionModelType {

    associatedtype Section
    associatedtype Item

    init(model: Section, items: [Item])

}

extension SectionModel: CombineSectionModelType { }
extension AnimatableSectionModel: CombineSectionModelType { }

struct BuilderTool {

    static func combineSections<S: _SectionNode, N: _Node, FlixSectionModel: CombineSectionModelType>(_ value: [(section: S, nodes: [N])?]) -> [FlixSectionModel]
        where FlixSectionModel.Item == N, FlixSectionModel.Section == S {
            return value.compactMap { $0 }.enumerated()
                .map { (offset, section) -> FlixSectionModel in
                    let items = section.nodes.map { (node) -> N in
                        var node = node
                        node.providerStartIndexPath.section = offset
                        node.providerEndIndexPath.section = offset
                        return node
                    }
                    return FlixSectionModel.init(model: section.section, items: items)
            }

    }

}

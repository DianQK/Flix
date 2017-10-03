//
//  TextNode.swift
//  FormDemo
//
//  Created by DianQK on 01/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import Foundation
import Flix

struct TextModel: Equatable, StringIdentifiableType {
    
    var identity: String {
        return self.text
    }
    
    static func ==(lhs: TextModel, rhs: TextModel) -> Bool {
        return lhs.text == rhs.text
    }

    let text: String
    
}

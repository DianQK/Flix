//
//  NeverHitSelfView.swift
//  Flix
//
//  Created by DianQK on 25/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

class NeverHitSelfView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let result = super.hitTest(point, with: event), result !== self else { return nil }
        return result
    }

}

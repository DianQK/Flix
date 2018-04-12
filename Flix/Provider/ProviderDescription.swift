//
//  ProviderDescription.swift
//  Flix
//
//  Created by DianQK on 24/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

public protocol FlixCustomStringConvertible: class, CustomStringConvertible { }

extension FlixCustomStringConvertible {

    public var description: String {
        return _flix_description
    }
    
    var _flix_description: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())>"
    }

    public var _flix_identity: String {
        if let customIdentity = (self as? CustomIdentityType)?.customIdentity {
            return "\(self._flix_description)-\(customIdentity)"
        } else {
            return self._flix_description
        }
    }

}

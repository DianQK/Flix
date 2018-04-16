//
//  PerformGroupUpdatesable.swift
//  Flix
//
//  Created by DianQK on 2018/4/16.
//  Copyright © 2018 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol PerformGroupUpdatesable {

    func beginGroupUpdates()

    func endGroupUpdates()

}

extension PerformGroupUpdatesable {

    public func performGroupUpdates(_ updates: (() -> Void)) {
        self.beginGroupUpdates(); defer { self.endGroupUpdates() }
        updates()
    }

}

private var performGroupUpdatesBehaviorRelayKey: Void?

extension PerformGroupUpdatesable where Self: Builder {

    var performGroupUpdatesBehaviorRelay: BehaviorRelay<Bool> {
        if let behaviorRelay = objc_getAssociatedObject(self, &performGroupUpdatesBehaviorRelayKey) as? BehaviorRelay<Bool> {
            return behaviorRelay
        } else {
            let behaviorRelay = BehaviorRelay(value: true)
            objc_setAssociatedObject(self, &performGroupUpdatesBehaviorRelayKey, behaviorRelay, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return behaviorRelay
        }
    }

    public func beginGroupUpdates() {
        self.performGroupUpdatesBehaviorRelay.accept(false)
    }

    public func endGroupUpdates() {
        self.performGroupUpdatesBehaviorRelay.accept(true)
    }

}

extension ObservableConvertibleType {

    func sendLatest<T: ObservableConvertibleType>(when: T) -> Observable<E> where T.E == Bool {
        return Observable.combineLatest(self.asObservable(), when.asObservable())
            .flatMap { (value, send) -> Observable<E> in
                return send ? Observable.just(value) : Observable.empty()
            }
    }

}

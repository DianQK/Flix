//
//  MKLocalSearch+Rx.swift
//  Example
//
//  Created by wc on 25/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import RxSwift
import CoreLocation
import MapKit

extension MKLocalSearch {
    
    convenience init(naturalLanguageQuery: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = naturalLanguageQuery
        self.init(request: request)
    }
    
}

extension Reactive where Base: MKLocalSearch {

    var start: Observable<MKLocalSearchResponse?> {
        return Observable.create({ [weak search = self.base] (observer) -> Disposable in
            guard let search = search else {
                observer.onCompleted()
                return Disposables.create()
            }
            search.start { (response, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(response)
                    observer.onCompleted()
                }
            }
            return Disposables.create {
                search.cancel()
            }
        })
    }

    var searchedPlacemarks: Observable<[CLPlacemark]> {
        return self.start.map { $0?.mapItems.map { $0.placemark } ?? [] }
    }

    static func search(naturalLanguageQuery: String) -> Observable<[CLPlacemark]> {
        return Observable.just(MKLocalSearch(naturalLanguageQuery: naturalLanguageQuery))
            .flatMap { $0.rx.searchedPlacemarks }
    }

}

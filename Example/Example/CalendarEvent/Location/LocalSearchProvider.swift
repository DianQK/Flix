//
//  LocalSearchProvider.swift
//  Example
//
//  Created by wc on 25/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import Flix
import CoreLocation
import MapKit
import RxSwift
import RxCocoa
import Contacts

class PlacemarkTableViewCell: UITableViewCell {

    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let locationImageView = UIImageView(image: #imageLiteral(resourceName: "Icon Location Red"))

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
        self.contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 56).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true

        self.contentView.addSubview(addressLabel)
        addressLabel.font = UIFont.systemFont(ofSize: 10)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor).isActive = true
        addressLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
        addressLabel.trailingAnchor.constraint(equalTo: self.nameLabel.trailingAnchor).isActive = true

        self.contentView.addSubview(locationImageView)
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        locationImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        locationImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CLPlacemark: StringIdentifiableType {

    public var identity: String {
        guard let location = self.location else {
            return ""
        }
        return "<longitude-\(location.coordinate.longitude),latitude-\(location.coordinate.latitude)>"
    }

}

extension CLPlacemark {

    var addressDetail: String? {
        guard let postalAddress = postalAddress else {
            return nil
        }
        return postalAddress.country + postalAddress.city + postalAddress.subLocality + postalAddress.street
    }

}

class LocalSearchProvider: AnimatableTableViewProvider, TableViewDeleteable {

    func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: CLPlacemark) {
        placemarkDeleted.onNext(value)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: CLPlacemark) -> Bool {
        return canDelete
    }

    func configureCell(_ tableView: UITableView, cell: PlacemarkTableViewCell, indexPath: IndexPath, value: CLPlacemark) {
        cell.nameLabel.text = value.name
        cell.addressLabel.text = value.addressDetail
    }

    func genteralValues() -> Observable<[CLPlacemark]> {
        return self.result
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: CLPlacemark) -> CGFloat? {
        return 56
    }

    func tap(_ tableView: UITableView, indexPath: IndexPath, value: CLPlacemark) {
        placemarkSelected.onNext(value)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    typealias Value = CLPlacemark
    typealias Cell = PlacemarkTableViewCell

    let naturalLanguageQuery: Observable<String>?
    let result: Observable<[CLPlacemark]>
    let placemarkSelected = PublishSubject<CLPlacemark>()
    let placemarkDeleted = PublishSubject<CLPlacemark>()
    var canDelete: Bool = false

    init(naturalLanguageQuery: Observable<String>) {
        self.naturalLanguageQuery = naturalLanguageQuery

        self.result = naturalLanguageQuery
            .distinctUntilChanged()
            .startWith("")
            .flatMapLatest { (query) -> Observable<[CLPlacemark]> in
                if query.isEmpty {
                    return Observable.just([])
                } else {
                    return MKLocalSearch.rx.search(naturalLanguageQuery: query).catchErrorJustReturn([])
                        .observeOn(MainScheduler.instance)
                }
            }
            .share(replay: 1, scope: .forever)
    }

    init(result: Observable<[CLPlacemark]>) {
        self.result = result
        self.naturalLanguageQuery = nil
    }

}

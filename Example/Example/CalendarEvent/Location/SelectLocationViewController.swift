//
//  SelectLocationViewController.swift
//  Example
//
//  Created by DianQK on 25/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix
import CoreLocation
import MapKit

class Storage {

    static var recentSelectedPlacemarks = BehaviorRelay(value: [CLPlacemark]())

}

class PlainTitleTableViewHeaderSectionProvider: UniqueCustomTableViewSectionProvider {

    let textLabel = UILabel()

    init(text: String) {
        super.init(tableElementKindSection: .header)
        self.sectionHeight = { _ in return 32 }
        textLabel.font = UIFont.boldSystemFont(ofSize: 15)
        textLabel.text = text
        self.contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }
    
}

extension LocalSearchProvider {

    static func createRecentSelectedPlacemarksProvider() -> LocalSearchProvider {
        return LocalSearchProvider(result: Storage.recentSelectedPlacemarks.asObservable())
    }

}

class SelectLocationViewController: UIViewController {
    
    let searchBar = UISearchBar()
    let tableView = UITableView(frame: .zero, style: .plain)
    
    let disposeBag = DisposeBag()
    
    let geocoder = CLGeocoder()

    let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: nil, action: nil)

    let didSelectLocation = PublishSubject<EventLocation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Location"

        self.searchBar.placeholder = "Enter Location"
        self.searchBar.tintColor = UIColor(named: "Bittersweet")
        _ = self.searchBar.becomeFirstResponder()

        self.view.backgroundColor = UIColor.white

        self.navigationItem.rightBarButtonItem = cancelBarButtonItem

        self.tableView.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
        self.tableView.sectionFooterHeight = CGFloat.leastNonzeroMagnitude
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.rowHeight = 44
        self.tableView.backgroundColor = UIColor(named: "Background")
        self.tableView.separatorColor = UIColor(named: "Background")
        
        self.view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo:  self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        let customLocalProvider = SingleUITableViewCellProvider()
        customLocalProvider.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
        let customLocalLabel = UILabel()
        customLocalProvider.contentView.addSubview(customLocalLabel)
        customLocalLabel.translatesAutoresizingMaskIntoConstraints = false
        customLocalLabel.leadingAnchor.constraint(equalTo: customLocalProvider.contentView.leadingAnchor, constant: 56).isActive = true
        customLocalLabel.centerYAnchor.constraint(equalTo: customLocalProvider.contentView.centerYAnchor).isActive = true

        let locationImageView = UIImageView(image: #imageLiteral(resourceName: "Icon Location Gray"))
        customLocalProvider.contentView.addSubview(locationImageView)
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        locationImageView.leadingAnchor.constraint(equalTo: customLocalProvider.contentView.leadingAnchor, constant: 15).isActive = true
        locationImageView.centerYAnchor.constraint(equalTo: customLocalProvider.contentView.centerYAnchor).isActive = true

        searchBar.rx.text.orEmpty.bind(to: customLocalLabel.rx.text).disposed(by: disposeBag)

        let currentLocationProvider = SingleUITableViewCellProvider()
        currentLocationProvider.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)

        let currentPlacemark = GeolocationService.instance.location.asObservable()
            .flatMap { (location) -> Observable<CLPlacemark?> in
                guard let location = location else { return Observable.just(nil) }
                let geocoder = CLGeocoder() // TODO
                return Observable.create({ (observer) -> Disposable in
                    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                        observer.onNext(placemarks?.first)
                        observer.onCompleted()
                    })
                    return Disposables.create {
                        geocoder.cancelGeocode()
                    }
                })
            }
            .share(replay: 1, scope: .forever)

        let currentLocalLabel = UILabel()
        currentLocalLabel.text = "Current Location"
        currentLocationProvider.contentView.addSubview(currentLocalLabel)
        currentLocalLabel.translatesAutoresizingMaskIntoConstraints = false
        currentLocalLabel.leadingAnchor.constraint(equalTo: currentLocationProvider.contentView.leadingAnchor, constant: 56).isActive = true
        currentLocalLabel.centerYAnchor.constraint(equalTo: currentLocationProvider.contentView.centerYAnchor).isActive = true

        GeolocationService.instance.authorized.asObservable()
            .map { !$0 }
            .bind(to: currentLocationProvider.rx.isHidden).disposed(by: disposeBag)

//        currentPlacemark.startWith(nil).map { $0 == nil }.bind(to: currentLocationProvider.isHidden).disposed(by: disposeBag)

        currentPlacemark.map { $0?.name ?? "" }.map { "Current Location " + $0 }
            .bind(to: currentLocalLabel.rx.text)
            .disposed(by: disposeBag)

        let currentlocationImageView = UIImageView(image: #imageLiteral(resourceName: "Icon Current Location"))
        currentLocationProvider.contentView.addSubview(currentlocationImageView)
        currentlocationImageView.translatesAutoresizingMaskIntoConstraints = false
        currentlocationImageView.leadingAnchor.constraint(equalTo: currentLocationProvider.contentView.leadingAnchor, constant: 20).isActive = true
        currentlocationImageView.centerYAnchor.constraint(equalTo: currentLocationProvider.contentView.centerYAnchor).isActive = true
        searchBar.rx.text.orEmpty.map { $0.isEmpty }
            .distinctUntilChanged()
            .bind(to: customLocalProvider.rx.isHidden)
            .disposed(by: disposeBag)

        let customLocalSectionProvider = AnimatableTableViewSectionProvider(providers: [customLocalProvider, currentLocationProvider])

        let recentSelectedPlacemarksProvider = LocalSearchProvider.createRecentSelectedPlacemarksProvider()
        recentSelectedPlacemarksProvider.canDelete = true
        recentSelectedPlacemarksProvider.event.modelDeleted
            .subscribe(onNext: { (placemark) in
                Storage.recentSelectedPlacemarks.accept(Storage.recentSelectedPlacemarks.value.filter({ $0.identity != placemark.identity }))
            })
            .disposed(by: disposeBag)
        let recentSelectedPlacemarksSectionProvider = AnimatableTableViewSectionProvider(
            providers: [recentSelectedPlacemarksProvider],
            headerProvider: PlainTitleTableViewHeaderSectionProvider(text: "Recents")
        )
        Storage.recentSelectedPlacemarks.asObservable().map { $0.isEmpty }
            .bind(to: recentSelectedPlacemarksSectionProvider.rx.isHidden)
            .disposed(by: disposeBag)

        let localSearchProvider = LocalSearchProvider(naturalLanguageQuery: searchBar.rx.text.orEmpty.asObservable())
        let localSearchSectionProvider = AnimatableTableViewSectionProvider(
            providers: [localSearchProvider],
            headerProvider: PlainTitleTableViewHeaderSectionProvider(text: "Locations")
        )
        localSearchProvider.event.modelSelected
            .subscribe(onNext: { [weak self] (placemark) in
                _ = self?.navigationController?.popViewController(animated: true)
                var recentSelectedPlacemarks = Storage.recentSelectedPlacemarks.value
                if let index = recentSelectedPlacemarks.index(where: { $0.identity == placemark.identity }) {
                    recentSelectedPlacemarks.remove(at: index)
                }
                recentSelectedPlacemarks.append(placemark)
                Storage.recentSelectedPlacemarks.accept(recentSelectedPlacemarks)
            })
            .disposed(by: disposeBag)

        localSearchProvider.result.map { $0.isEmpty }
            .distinctUntilChanged()
            .bind(to: localSearchSectionProvider.rx.isHidden)
            .disposed(by: disposeBag)

        Observable<EventLocation>
            .merge(
                [
                    customLocalProvider.event.selectedEvent.withLatestFrom(searchBar.rx.text.orEmpty).map { EventLocation.custom($0) },
                    currentLocationProvider.event.selectedEvent.withLatestFrom(currentPlacemark.filter { $0 != nil }.map { EventLocation.placemark($0!) }),
                    recentSelectedPlacemarksProvider.event.modelSelected.map { EventLocation.placemark($0) },
                    localSearchProvider.event.modelSelected.asObservable().map { EventLocation.placemark($0) }
                ]
            )
            .bind(to: didSelectLocation)
            .disposed(by: disposeBag)

        self.tableView.flix.animatable
            .build([
                customLocalSectionProvider,
                recentSelectedPlacemarksSectionProvider,
                localSearchSectionProvider
                ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = self.searchBar.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = self.searchBar.resignFirstResponder()
    }

}

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }

        return
    }

    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

extension Reactive where Base: SelectLocationViewController {

    var didCancel: ControlEvent<()> {
        return self.base.cancelBarButtonItem.rx.tap
    }

    static func createWithParent(_ parent: UIViewController?, configure: @escaping (SelectLocationViewController) throws -> () = { x in }) -> Observable<SelectLocationViewController> {
        return Observable.create { [weak parent] observer in
            let selectLocation = SelectLocationViewController()
            let dismissDisposable = selectLocation.rx
                .didCancel
                .subscribe(onNext: { [weak selectLocation] _ in
                    guard let selectLocation = selectLocation else {
                        return
                    }
                    dismissViewController(selectLocation, animated: true)
                })

            do {
                try configure(selectLocation)
            }
            catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }

            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }

            let nav = UINavigationController(rootViewController: selectLocation)
            parent.present(nav, animated: true, completion: nil)
            observer.on(.next(selectLocation))

            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(selectLocation, animated: true)
            })
        }
    }
}

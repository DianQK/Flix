//
//  DeleteItemViewController.swift
//  Example
//
//  Created by DianQK on 07/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

struct Tag: StringIdentifiableType, Equatable {

    let id: Int
    let name = BehaviorRelay(value: "")

    var identity: String {
        return "\(id)"
    }

    static func ==(lfs: Tag, rhs: Tag) -> Bool {
        return lfs.id == rhs.id && lfs.name === rhs.name
    }

}

class TagTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let textField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        self.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        textField.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var reuseBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
}

class InputTagsProvider: AnimatableTableViewProvider, TableViewDeleteable {

    typealias Cell = TagTableViewCell
    typealias Value = Tag
    
    let tags = BehaviorRelay<[Tag]>(value: [])

    func configureCell(_ tableView: UITableView, cell: TagTableViewCell, indexPath: IndexPath, value: Tag) {
        cell.textField.placeholder = "Tag Name"
        (cell.textField.rx.textInput <-> value.name).disposed(by: cell.reuseBag)
    }
    
    func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: Tag) {
        self.removeItem(id: value.id)
    }
    
    func createValues() -> Observable<[Tag]> {
        return tags.asObservable()
    }
    
    func addItem() {
        let maxId = self.tags.value.max { (lhs, rhs) -> Bool in return lhs.id < rhs.id }?.id ?? 0
        self.tags.accept(self.tags.value + [Tag(id: maxId + 1)])
    }
    
    func removeItem(id: Int) {
        self.tags.accept(self.tags.value.filter({ $0.id != id }))
    }
    
}

class DeleteItemViewController: TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Delete"
        
        let inputTagsProvider = InputTagsProvider()
        inputTagsProvider.tags.accept([Tag(id: 1)])
        
        let addNewTagProvider = SingleUITableViewCellProvider()
        let addNewTagImageView = UIImageView(image: #imageLiteral(resourceName: "Control Add"))
        addNewTagProvider.contentView.addSubview(addNewTagImageView)
        addNewTagImageView.translatesAutoresizingMaskIntoConstraints = false
        addNewTagImageView.leadingAnchor.constraint(equalTo: addNewTagProvider.contentView.leadingAnchor, constant: 15).isActive = true
        addNewTagImageView.centerYAnchor.constraint(equalTo: addNewTagProvider.contentView.centerYAnchor, constant: 3).isActive = true
        
        let addNewTagTitleLabel = UILabel()
        addNewTagTitleLabel.text = "Add New Tag"
        addNewTagProvider.contentView.addSubview(addNewTagTitleLabel)
        addNewTagTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addNewTagTitleLabel.leadingAnchor.constraint(equalTo: addNewTagImageView.trailingAnchor, constant: 15).isActive = true
        addNewTagTitleLabel.centerYAnchor.constraint(equalTo: addNewTagProvider.contentView.centerYAnchor, constant: 0).isActive = true
        
        addNewTagProvider.event.selectedEvent.asObservable()
            .subscribe(onNext: {
                inputTagsProvider.addItem()
            })
            .disposed(by: disposeBag)
        
        self.tableView.flix.animatable.build([inputTagsProvider, addNewTagProvider])

    }
    
}

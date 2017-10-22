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

struct Tag {
    let id: Int
    let name = Variable("")
}

struct TagWarp: StringIdentifiableType, Equatable {

    static func ==(lhs: TagWarp, rhs: TagWarp) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    let identity: String
    let tag: Tag
    
    init(providerIdentity: String, tag: Tag) {
        self.identity = providerIdentity + "\(tag.id)"
        self.tag = tag
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
    typealias Value = TagWarp
    
    let identity: String
    let tags = Variable<[Tag]>([])
    
    init(identity: String) {
        self.identity = identity
    }
    
    func configureCell(_ tableView: UITableView, cell: TagTableViewCell, indexPath: IndexPath, value: TagWarp) {
        cell.textField.placeholder = "Tag Name"
        (cell.textField.rx.textInput <-> value.tag.name).disposed(by: cell.reuseBag)
    }
    
    func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: TagWarp) {
        self.removeItem(id: value.tag.id)
    }
    
    func genteralValues() -> Observable<[TagWarp]> {
        let providerIdentity = self.identity
        return tags.asObservable()
            .map { $0.map { TagWarp(providerIdentity: providerIdentity, tag: $0) } }
    }
    
    func addItem() {
        let maxId = self.tags.value.max { (lhs, rhs) -> Bool in return lhs.id < rhs.id }?.id ?? 0
        self.tags.value.append(Tag(id: maxId + 1))
    }
    
    func removeItem(id: Int) {
        if let index = self.tags.value.index(where: { $0.id == id }) {
            self.tags.value.remove(at: index)
        }
    }
    
}

class DeleteItemViewController: TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inputTagsProvider = InputTagsProvider(identity: "inputTagsProvider")
        inputTagsProvider.tags.value = [Tag(id: 1)]
        
        let addNewTagProvider = UniqueCustomTableViewProvider(identity: "addNewTagProvider")
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
        
        addNewTagProvider.tap.asObservable()
            .subscribe(onNext: {
                inputTagsProvider.addItem()
            })
            .disposed(by: disposeBag)
        
        self.tableViewBuilder = AnimatableTableViewBuilder(
            tableView: tableView,
            providers: [inputTagsProvider, addNewTagProvider]
        )
        
    }
    
}

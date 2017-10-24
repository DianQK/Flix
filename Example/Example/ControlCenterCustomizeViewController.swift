//
//  ControlCenterCustomizeViewController.swift
//  Example
//
//  Created by DianQK on 20/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

extension String: StringIdentifiableType {
    
    public var identity: String {
        return self
    }
    
}

class IncludeControlProvider: AnimatableTableViewProvider, TableViewMoveable, TableViewDeleteable {
    
    typealias Cell = UITableViewCell
    typealias Value = String
    
    let values = Variable(["手电筒", "计时器", "计算器", "低电量模式", "屏幕录制", "备忘录", "闹钟", "相机"])
    
    let itemDeleted = PublishSubject<String>()

    func configureCell(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, value: String) {
        cell.textLabel?.text = value
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndex: Int, to destinationIndex: Int, value: String) {
        var result = values.value
        result.remove(at: sourceIndex)
        result.insert(value, at: destinationIndex)
        values.value = result
    }
    
    func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: String) {
        if let index = values.value.index(of: value) {
            values.value.remove(at: index)
        }
        itemDeleted.onNext(value)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, value: String) -> String? {
        return "移除"
    }
    
    func insertNew(_ value: String) {
        self.values.value.append(value)
    }
    
    func genteralValues() -> Observable<[String]> {
        return values.asObservable()
    }
    
}

class MoreControlProvider: AnimatableTableViewProvider, TableViewInsertable {
    
    typealias Cell = UITableViewCell
    typealias Value = String
    
    let values = Variable(["放大器", "辅助功能快捷键", "驾驶勿扰", "秒表", "文字大小", "引导式访问", "语音备忘录", "Apple TV Remote 遥控器", "Wallet"])
    
    let itemInserted = PublishSubject<String>()
    
    func configureCell(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, value: String) {
        cell.textLabel?.text = value
    }
    
    func tableView(_ tableView: UITableView, itemInsertedForRowAt indexPath: IndexPath, value: String) {
        if let index = values.value.index(of: value) {
            values.value.remove(at: index)
        }
        itemInserted.onNext(value)
    }
    
    func insertNew(_ value: String) {
        self.values.value.append(value)
    }

    func genteralValues() -> Observable<[String]> {
        return values.asObservable().map { $0.sorted() }
    }

}

class TitleTableViewSectionProvider: UniqueCustomTableViewSectionProvider {
    
    let titleLabel = UILabel()
    
    override init(tableElementKindSection: UITableElementKindSection) {
        super.init(tableElementKindSection: tableElementKindSection)
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor(named: "CommentText")
        titleLabel.numberOfLines = 0
        
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    override func tableView(_ tableView: UITableView, heightInSection section: Int, value: UniqueCustomTableViewSectionProvider) -> CGFloat? {
        let height = NSAttributedString(string: titleLabel.text ?? "", attributes: [
            .font: UIFont.systemFont(ofSize: 13)
            ])
            .boundingRect(
            with: CGSize(width: tableView.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil).height
        return height + 16
    }
    
}

class ControlCenterCustomizeViewController: TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "自定"
        
        let tipHeaderSectionProvider = UniqueCustomTableViewSectionProvider(tableElementKindSection: .header)
        tipHeaderSectionProvider.sectionHeight = { return 110 }
        let tipLabel = UILabel()
        tipLabel.text = "添加和整理显示在“控制中心”中的附加控制。"
        tipLabel.numberOfLines = 0
        tipLabel.font = UIFont.systemFont(ofSize: 17)
        tipLabel.textAlignment = .center
        tipHeaderSectionProvider.contentView.addSubview(tipLabel)
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.centerYAnchor.constraint(equalTo: tipHeaderSectionProvider.contentView.centerYAnchor).isActive = true
        tipLabel.leadingAnchor.constraint(equalTo: tipHeaderSectionProvider.contentView.leadingAnchor, constant: 35).isActive = true
        tipLabel.trailingAnchor.constraint(equalTo: tipHeaderSectionProvider.contentView.trailingAnchor, constant: -35).isActive = true
        let tipSectionProvider = AnimatableTableViewSectionProvider(
            providers: [],
            headerProvider: tipHeaderSectionProvider
        )
        
        let includeControlProvider = IncludeControlProvider()
        
        let includeControlTitleHeaderSectionProvider = TitleTableViewSectionProvider(tableElementKindSection: .header)
        includeControlTitleHeaderSectionProvider.titleLabel.text = "包括"
        
        let includeControlFooterSectionProvider = UniqueCustomTableViewSectionProvider(tableElementKindSection: .footer)
        includeControlFooterSectionProvider.sectionHeight = { return 30 }

        let includeControlSectionProvider = AnimatableTableViewSectionProvider(
            providers: [includeControlProvider],
            headerProvider: includeControlTitleHeaderSectionProvider,
            footerProvider: includeControlFooterSectionProvider
        )

        let moreControlProvider = MoreControlProvider()
        
        let moreControlTitleHeaderSectionProvider = TitleTableViewSectionProvider(tableElementKindSection: .header)
        moreControlTitleHeaderSectionProvider.titleLabel.text = "更多控制"

        let moreControlSectionProvider = AnimatableTableViewSectionProvider(
            providers: [moreControlProvider],
            headerProvider: moreControlTitleHeaderSectionProvider
        )
        
        includeControlProvider.itemDeleted
            .subscribe(onNext: { (value) in
                moreControlProvider.insertNew(value)
            })
            .disposed(by: disposeBag)

        moreControlProvider.itemInserted
            .subscribe(onNext: { (value) in
                includeControlProvider.insertNew(value)
            })
            .disposed(by: disposeBag)
        
        self.tableView.flix.animatable.build([tipSectionProvider, includeControlSectionProvider, moreControlSectionProvider])
        
        self.tableView.setEditing(true, animated: false)

    }

}

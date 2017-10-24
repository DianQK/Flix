//
//  NestFormViewController.swift
//  Example
//
//  Created by DianQK on 06/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

struct HardwareForm {
    
    let name = Variable("")
    let count = Variable("")
    let unitPrice = Variable("")
    let id: Int
    
}

enum _HardwareFormItem: Equatable {

    static func ==(lhs: _HardwareFormItem, rhs: _HardwareFormItem) -> Bool {
        return true
    }

    case name(Variable<String>)
    case count(Variable<String>)
    case unitPrice(Variable<String>)
    case delete
    
}

struct HardwareFormItem: Equatable, StringIdentifiableType {
    
    static func ==(lhs: HardwareFormItem, rhs: HardwareFormItem) -> Bool {
        return lhs.item == rhs.item
    }
    
    var identity: String {
        switch self.item {
        case .count:
            return "count" + String(id)
        case .name:
            return "name" + String(id)
        case .unitPrice:
            return "unitPrice" + String(id)
        case .delete:
            return "delete" + String(id)
        }
    }
    
    let id: Int
    let item: _HardwareFormItem
    
    init(id: Int, item: _HardwareFormItem) {
        self.id = id
        self.item = item
    }
    
}

class ItemInputTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let textField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none

        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        
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

class TextTableViewCell: UITableViewCell {
    
    let contentLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentLabel.textAlignment = .center
        self.contentView.addSubview(contentLabel)
        self.contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        contentLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class HardwareFormProvider: AnimatableTableViewMultiNodeProvider {

    typealias Value = HardwareFormItem
    
    let hardwareForms = Variable([HardwareForm]())
    
    func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: HardwareFormItem) -> UITableViewCell {
        switch value.item {
        case let .name(name):
            let cell = tableView.dequeueReusableCell(withIdentifier: _flix_identity + "NameUITableViewCell", for: indexPath) as! ItemInputTableViewCell
            cell.titleLabel.text = "品名"
            cell.textField.keyboardType = .default
            (cell.textField.rx.textInput <-> name).disposed(by: cell.reuseBag)
            return cell
        case let .count(count):
            let cell = tableView.dequeueReusableCell(withIdentifier: _flix_identity + "CountUITableViewCell", for: indexPath) as! ItemInputTableViewCell
            cell.titleLabel.text = "数量"
            cell.textField.keyboardType = .numberPad
            (cell.textField.rx.textInput <-> count).disposed(by: cell.reuseBag)
            return cell
        case let .unitPrice(unitPrice):
            let cell = tableView.dequeueReusableCell(withIdentifier: _flix_identity + "UnitPriceUITableViewCell", for: indexPath) as! ItemInputTableViewCell
            cell.titleLabel.text = "单价"
            cell.textField.keyboardType = .numberPad
            (cell.textField.rx.textInput <-> unitPrice).disposed(by: cell.reuseBag)
            return cell
        case .delete:
            let cell = tableView.dequeueReusableCell(withIdentifier: _flix_identity + "DeleteUITableViewCell", for: indexPath) as! TextTableViewCell
            cell.contentLabel.textColor = UIColor.white
            cell.backgroundColor = UIColor.red
            cell.selectionStyle = .none
            cell.contentLabel.text = "删除"
            return cell
        }
    }
    
    func addItem() {
        let maxId = self.hardwareForms.value.max { (lhs, rhs) -> Bool in return lhs.id < rhs.id }?.id ?? 0
        self.hardwareForms.value.append(HardwareForm(id: maxId + 1))
    }
    
    func removeItem(id: Int) {
        if let index = self.hardwareForms.value.index(where: { $0.id == id }) {
            self.hardwareForms.value.remove(at: index)
        }
    }

    func tap(_ tableView: UITableView, indexPath: IndexPath, value: HardwareFormItem) {
        switch value.item {
        case .delete:
            self.removeItem(id: value.id)
        default:
            break
        }
    }
    
    func genteralValues() -> Observable<[HardwareFormItem]> {
        return self.hardwareForms.asObservable()
            .map { (forms: [HardwareForm]) -> [HardwareFormItem] in
                forms.flatMap({ (form: HardwareForm) -> [HardwareFormItem] in
                    return [
                        HardwareFormItem(id: form.id, item: .name(form.name)),
                        HardwareFormItem(id: form.id, item: .count(form.count)),
                        HardwareFormItem(id: form.id, item: .unitPrice(form.unitPrice)),
                        HardwareFormItem(id: form.id, item: .delete)
                    ]
                })
        }
    }

    func register(_ tableView: UITableView) {
        tableView.register(ItemInputTableViewCell.self, forCellReuseIdentifier: _flix_identity + "NameUITableViewCell")
        tableView.register(ItemInputTableViewCell.self, forCellReuseIdentifier: _flix_identity + "CountUITableViewCell")
        tableView.register(ItemInputTableViewCell.self, forCellReuseIdentifier: _flix_identity + "UnitPriceUITableViewCell")
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: _flix_identity + "DeleteUITableViewCell")
    }

}

class UniqueTitleTableViewProvider: UniqueCustomTableViewProvider {
    
    let titleLabel = UILabel()
    
    override init() {
        super.init()
        self.itemHeight = { return 60 }
        self.selectionStyle.value = .none
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.text = "基本信息"
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
    }
    
}

class UniqueItemInputTableViewProvider: UniqueCustomTableViewProvider {
    
    let titleLabel = UILabel()
    let textField = UITextField()
    
    override init() {
        super.init()
        
        selectionStyle.value = .none
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
    }
    
}

class NestFormViewController: TableViewController {
    
    let titleProvider: UniqueTitleTableViewProvider = {
        let provider = UniqueTitleTableViewProvider()
        provider.titleLabel.text = "基本信息"
        return provider
    }()
    
    let titleInputProvider: UniqueItemInputTableViewProvider = {
        let provider = UniqueItemInputTableViewProvider()
        provider.titleLabel.text = "标题"
        return provider
    }()
    
    let configurationTitleProvider: UniqueTitleTableViewProvider = {
        let provider = UniqueTitleTableViewProvider()
        provider.titleLabel.text = "配置"
        return provider
    }()
    
    let addProvider: UniqueButtonTableViewProvider = {
        let provider = UniqueButtonTableViewProvider()
        provider.textLabel.textColor = UIColor.white
        provider.textLabel.text = "添加"
        provider.backgroundView?.backgroundColor = UIColor(named: "Ufo Green")!
        provider.selectedBackgroundView?.backgroundColor = UIColor(named: "Eucalyptus")!
        return provider
    }()
    
    let hardwareFormProvider = HardwareFormProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "嵌套表单"

        hardwareFormProvider.hardwareForms.value = [HardwareForm(id: 1)]
        
        let fillFormSectionProvider = AnimatableTableViewSectionProvider(
            providers: [titleProvider, titleInputProvider, configurationTitleProvider, hardwareFormProvider]
        )
        
        let addHeaderProvider: UniqueCustomTableViewSectionProvider = {
            let provider = UniqueCustomTableViewSectionProvider(tableElementKindSection: .header)
            provider.sectionHeight = { return 20 }
            return provider
        }()
        
        let addSectionProvider = AnimatableTableViewSectionProvider(
            providers: [addProvider],
            headerProvider: addHeaderProvider
        )
        
        addProvider.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.hardwareFormProvider.addItem()
            })
            .disposed(by: disposeBag)
        
        self.tableView.flix.animatable.build([fillFormSectionProvider, addSectionProvider])

    }
    
}

//
//  NestFormViewController.swift
//  Demo
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
            return providerIdentity + "count" + String(id)
        case .name:
            return providerIdentity + "name" + String(id)
        case .unitPrice:
            return providerIdentity + "unitPrice" + String(id)
        case .delete:
            return providerIdentity + "delete" + String(id)
        }
    }
    
    let id: Int
    let providerIdentity: String
    let item: _HardwareFormItem
    
    init(id: Int, providerIdentity: String, item: _HardwareFormItem) {
        self.id = id
        self.providerIdentity = providerIdentity
        self.item = item
    }
    
}

class ItemInputTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let textField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        
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
    
    let identity: String
    
    init(identity: String) {
        self.identity = identity
    }
    
    func configureCell(_ tableView: UITableView, indexPath: IndexPath, node: HardwareFormItem) -> UITableViewCell {
        switch node.item {
        case let .name(name):
            let cell = tableView.dequeueReusableCell(withIdentifier: identity + "NameUITableViewCell", for: indexPath) as! ItemInputTableViewCell
            cell.titleLabel.text = "品名"
            cell.textField.keyboardType = .default
            (cell.textField.rx.textInput <-> name).disposed(by: cell.reuseBag)
            return cell
        case let .count(count):
            let cell = tableView.dequeueReusableCell(withIdentifier: identity + "CountUITableViewCell", for: indexPath) as! ItemInputTableViewCell
            cell.titleLabel.text = "数量"
            cell.textField.keyboardType = .numberPad
            (cell.textField.rx.textInput <-> count).disposed(by: cell.reuseBag)
            return cell
        case let .unitPrice(unitPrice):
            let cell = tableView.dequeueReusableCell(withIdentifier: identity + "UnitPriceUITableViewCell", for: indexPath) as! ItemInputTableViewCell
            cell.titleLabel.text = "单价"
            cell.textField.keyboardType = .numberPad
            (cell.textField.rx.textInput <-> unitPrice).disposed(by: cell.reuseBag)
            return cell
        case .delete:
            let cell = tableView.dequeueReusableCell(withIdentifier: identity + "DeleteUITableViewCell", for: indexPath) as! TextTableViewCell
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

    func tap(_ tableView: UITableView, indexPath: IndexPath, node: HardwareFormItem) {
        switch node.item {
        case .delete:
            self.removeItem(id: node.id)
        default:
            break
        }
    }
    
    func genteralNodes() -> Observable<[HardwareFormItem]> {
        let providerIdentity = self.identity
        return self.hardwareForms.asObservable()
            .map { (forms: [HardwareForm]) -> [HardwareFormItem] in
                forms.flatMap({ (form: HardwareForm) -> [HardwareFormItem] in
                    return [
                        HardwareFormItem(id: form.id, providerIdentity: providerIdentity, item: .name(form.name)),
                        HardwareFormItem(id: form.id, providerIdentity: providerIdentity, item: .count(form.count)),
                        HardwareFormItem(id: form.id, providerIdentity: providerIdentity, item: .unitPrice(form.unitPrice)),
                        HardwareFormItem(id: form.id, providerIdentity: providerIdentity, item: .delete)
                    ]
                })
        }
    }

    public func genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        let providerIdentity = self.identity
        return genteralNodes()
            .map { $0.map { IdentifiableNode(node: IdentifiableValueNode(providerIdentity: providerIdentity, value: $0)) } }
    }

    func register(_ tableView: UITableView) {
        tableView.register(ItemInputTableViewCell.self, forCellReuseIdentifier: identity + "NameUITableViewCell")
        tableView.register(ItemInputTableViewCell.self, forCellReuseIdentifier: identity + "CountUITableViewCell")
        tableView.register(ItemInputTableViewCell.self, forCellReuseIdentifier: identity + "UnitPriceUITableViewCell")
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: identity + "DeleteUITableViewCell")
    }
    
}

class UniqueTitleTableViewProvider: UniqueCustomTableViewProvider {
    
    let titleLabel = UILabel()
    
    override init(identity: String) {
        super.init(identity: identity)
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
    
    override init(identity: String) {
        super.init(identity: identity)
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
    }
    
}

class NestFormViewController: TableViewController {
    
    let titleProvider: UniqueTitleTableViewProvider = {
        let provider = UniqueTitleTableViewProvider(identity: "titleProvider")
        provider.titleLabel.text = "基本信息"
        return provider
    }()
    
    let titleInputProvider: UniqueItemInputTableViewProvider = {
        let provider = UniqueItemInputTableViewProvider(identity: "titleInputProvider")
        provider.titleLabel.text = "标题"
        return provider
    }()
    
    let configurationTitleProvider: UniqueTitleTableViewProvider = {
        let provider = UniqueTitleTableViewProvider(identity: "configurationTitleProvider")
        provider.titleLabel.text = "配置"
        return provider
    }()
    
    let addProvider: UniqueButtonTableViewProvider = {
        let provider = UniqueButtonTableViewProvider(identity: "addProvider")
        provider.textLabel.textColor = UIColor.white
        provider.textLabel.text = "添加"
        provider.backgroundView?.backgroundColor = UIColor(named: "Ufo Green")!
        provider.selectedBackgroundView?.backgroundColor = UIColor(named: "Eucalyptus")!
        return provider
    }()
    
    let hardwareFormProvider = HardwareFormProvider(identity: "HardwareFormProvider")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "嵌套表单"

        hardwareFormProvider.hardwareForms.value = [HardwareForm(id: 1)]
        
        let fillFormProviderBuilder = SectionProviderTableViewBuilder(
            identity: "fillFormProviderBuilder",
            providers: [titleProvider, titleInputProvider, configurationTitleProvider, hardwareFormProvider]
        )
        
        let addHeaderProvider: UniqueCustomTableViewSectionProvider = {
            let provider = UniqueCustomTableViewSectionProvider(
                identity: "addHeaderProvider",
                tableElementKindSection: UITableElementKindSection.header
            )
            provider.sectionHeight = { return 20 }
            return provider
        }()
        
        let addProviderBuilder = SectionProviderTableViewBuilder(
            identity: "addProviderBuilder",
            providers: [addProvider],
            headerProvider: addHeaderProvider,
            footerProvider: nil
        )
        
        addProvider.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.hardwareFormProvider.addItem()
            })
            .disposed(by: disposeBag)
        
        self.tableViewService = AnimatableTableViewService(
            tableView: tableView,
            sectionProviderBuilders: [fillFormProviderBuilder, addProviderBuilder]
        )

    }
    
}

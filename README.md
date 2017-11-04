![Flix: iOS form builder in Swift](Flix.png)

[![Travis CI](https://travis-ci.org/DianQK/Flix.svg?branch=master)](https://travis-ci.org/DianQK/Flix)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Flix.svg)](https://cocoapods.org/pods/Flix)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Flix is flexible iOS framework to create dynamic forms with `UITableView` or `UICollectionView`.

## Features

- [x] Support no reused when you need.
- [x] Support reused for list when you need.
- [x] Support nest form.
- [x] Support add, delete and insert
- [x] Support Storyboard
- [x] Example app
- [x] Works with `UITableView` and `UICollectionView`

Flix focus on combining cells of `UICollectionView` or `UITableView`, it don't care about the view layout, business logic. So you can easily build custom form using Flix.

## Preview

![](screenshot.png)

## Requirements

- Xcode 9.0+
- Swift 4.0+
- RxSwift 4.0+
- RxDataSources 3.0+

## Installation

### CocoaPods

```ruby
pod 'Flix', '~> 0.7'
```

### Carthage

```
github "DianQK/Flix" ~> 0.7
```

## Principle

![](block_diagram.png)

Each provider will generate a number of nodes (cells), then combine those providers according to the sequence.

## Tutorial - A Simple Settings Pages

创建一个设置页时，我们希望每一个 Cell 都不会被复用，就好像在使用 Static `UITableView`。

比如在 iOS 11 上 Settings 中的个人信息 Cell，创建一个 `UniqueCustomTableViewProvider`，配置好样式并添加好相应的视图即可：

```swift
let profileProvider = UniqueCustomTableViewProvider()
profileProvider.itemHeight = { return 80 }
profileProvider.accessoryType = .disclosureIndicator
let avatarImageView = UIImageView(image: #imageLiteral(resourceName: "Flix Icon"))
profileProvider.contentView.addSubview(avatarImageView)

let nameLabel = UILabel()
nameLabel.text = "Flix"
profileProvider.contentView.addSubview(nameLabel)

let subTitleLabel = UILabel()
subTitleLabel.text = "Apple ID, iCloud, iTunes & App Store"
profileProvider.contentView.addSubview(subTitleLabel)

self.tableView.flix.build([profileProvider])
```

(效果图)

考虑到 `profileProvider` 有可能被复用，为 `profileProvider` 创建一个类管理所有的视图是更好的方案。

你可以直接继承 `UniqueCustomTableViewProvider`：

```swift
class ProfileProvider: UniqueCustomTableViewProvider {

    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let subTitleLabel = UILabel()

    init(avatar: UIImage, name: String) {
        super.init()

        self.itemHeight = { return 80 }
        self.accessoryType = .disclosureIndicator

        avatarImageView.image = avatar
        self.contentView.addSubview(avatarImageView)

        nameLabel.text = name
        self.contentView.addSubview(nameLabel)

        subTitleLabel.text = "Apple ID, iCloud, iTunes & App Store"
        self.contentView.addSubview(subTitleLabel)
    }

}
```

或者直接实现协议 `UniqueAnimatableTableViewProvider`：

```swift
class ProfileProvider: UniqueAnimatableTableViewProvider {

    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let subTitleLabel = UILabel()

    init(avatar: UIImage, name: String) {
        avatarImageView.image = avatar
        nameLabel.text = name
        subTitleLabel.text = "Apple ID, iCloud, iTunes & App Store"
    }

    func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        cell.accessoryType = .disclosureIndicator
        cell.contentView.addSubview(avatarImageView)
        cell.contentView.addSubview(nameLabel)
        cell.contentView.addSubview(subTitleLabel)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: ProfileProvider) -> CGFloat? {
        return 80
    }

}
```

看起来还不够，实际的 Settings 中用户信息是被放在一个单独的 Section 中的。我们可以为这个 `profileProvider` 包一层 `SectionProvider`：

```swift
let profileSectionProvider = SpacingSectionProvider(providers: [profileProvider], headerHeight: 35, footerHeight: 0)
self.tableView.flix.build([profileSectionProvider])
```

最后我们还可以创建更多的 Provider 构建一个更完整的 Settings 列表：

```swift
let profileProvider = ProfileProvider(avatar: #imageLiteral(resourceName: "Flix Icon"), name: "Flix")
let profileSectionProvider = SpacingSectionProvider(providers: [profileProvider], headerHeight: 35, footerHeight: 0)

let airplaneModeProvider = SwitchTableViewCellProvider(title: "Airplane Mode", icon: #imageLiteral(resourceName: "Airplane Icon"), isOn: false)
let wifiProvider = DescriptionTableViewCellProvider(title: "Wi-Fi", icon: #imageLiteral(resourceName: "Wifi Icon"), description: "Flix_5G")
let bluetoothProvider = DescriptionTableViewCellProvider(title: "Bluetooth", icon: #imageLiteral(resourceName: "Bluetooth Icon"), description: "On")
let cellularProvider = DescriptionTableViewCellProvider(title: "Cellular", icon: #imageLiteral(resourceName: "Cellular Icon"))
let personalHotspotProvider = DescriptionTableViewCellProvider(title: "Personal Hotspot", icon: #imageLiteral(resourceName: "Personal Hotspot Icon"), description: "Off")
let carrierProvider = DescriptionTableViewCellProvider(title: "Carrier", icon: #imageLiteral(resourceName: "Carrier Icon"), description: "AT&T")

let networkSectionProvider = SpacingSectionProvider(
    providers: [
        airplaneModeProvider,
        wifiProvider,
        bluetoothProvider,
        cellularProvider,
        personalHotspotProvider,
        carrierProvider
    ],
    headerHeight: 35,
    footerHeight: 0
)

self.tableView.flix.build([profileSectionProvider, networkSectionProvider])
```

以上内容仅仅是构建一个简单的设置页面，实际上 Flix 支持更多构建列表视图的方案，比如可复用的列表项展示、动态添加删除 Cell。

## 使用

因为 `CollectionViewProvider` 和 `TableViewProvider` 几乎一样，我们全部以 `UITableView` 的构建解释每一个 Provider 的使用方法。

> 你也可以在示例中找到全部的 `CollectionViewProvider` 使用示例。

注意：所有的 `AnimatableProvider` 生成的 Value (Node) 都需要服从协议 `StringIdentifiableType` 和 `Equatable`。
`StringIdentifiableType` 用于描述一个 Value（Node）是否为同一个 Value。
`Equatable` 用于描述同一个 Value 是否有更新。

### `UniqueCustomTableViewProvider` 使用

当构建一个诸如登录页面、个人页或设置页时，我们希望某些 Cell 不需要被重用（有时这个 Cell 在整个 `UITableView` 中仅存在一个），那么使用 `UniqueCustomTableViewProvider` 可以完全忽略重用的问题（通过在 `UITableView` 中注册一个全局唯一的 Cell）。

`UniqueCustomTableViewProvider` 中的 `contentView` 类似于 `UITableViewCell` 中的 `contentView` ，你可以直接添加对应的视图到 `contentView` 中。

`itemHeight` 用于返回 Cell 的高度，`tap` 是该 `Provider` / `Cell` 的点击事件。

如果你想完全定制一个唯一 Cell ，你也可以通过服从协议 `UniqueAnimatableTableViewProvider` 完成。

## `AnimatableTableViewMultiNodeProvider` 和 `AnimatableTableViewProvider`

两个 `Provider` 都支持局部更新 `UITableView` （即更新时不调用 `reloadData`）。

在 `genteralValues() -> Observable<[Value]>` 方法中实现你的 Provider 生成 Node 的方法。

## `AnimatablePartionSectionTableViewProvider` 和 `AnimatableTableViewSectionProvider`

`AnimatablePartionSectionTableViewProvider` 和 `AnimatableTableViewSectionProvider` 提供了构建 Section 的支持。
`AnimatablePartionSectionTableViewProvider` 用于构建 Section 的 Header 和 Footer，`AnimatableTableViewSectionProvider` 用于组合 `AnimatablePartionSectionTableViewProvider` 和 `AnimatableProvider`。

`AnimatablePartionSectionTableViewProvider` 的使用类似于 `AnimatableTableViewProvider`，在使用时，你需要注意这个 `Provider` 是 Header 还是 Footer。

比如：

```swift
let footerProvider = UniqueCustomTableViewSectionProvider(tableElementKindSection: .header)
let sectionProvider = AnimatableTableViewSectionProvider(
    providers: [],
    footerProvider: footerProvider
)
```

就是一个错误的用法。

## 构建

通过调用 `tableView.flix.build(_:)` 或 `tableView.flix.animatable.build(_:)` 构建全部的 Cell。`tableView.flix.animatable.build(_:)` 中传入的 Provider 必须都是 `AnimatableProvider` 。

当你需要调换 provider 的是顺序时，可以直接再次调用 `build` 方法，

其余详细使用方法，可以参考 Example 中的一些示例。

## Contributing

1. Please fork this project
2. Implement new methods or changes。
3. Write appropriate docs and comments in the README.md
4. Submit a pull request.

## Contact

Raise an [Issue](https://github.com/DianQK/Flix/issues) or hit me up on Twitter [@Songxut](https://twitter.com/Songxut).

You can also join Telegram Group https://t.me/Flix_iOS.

## License ##

Flix is released under an MIT license. See LICENSE for more information.

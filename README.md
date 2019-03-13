![Flix: iOS form builder in Swift](Flix.png)

[![Travis CI](https://travis-ci.org/DianQK/Flix.svg?branch=master)](https://travis-ci.org/DianQK/Flix)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Flix.svg)](https://cocoapods.org/pods/Flix)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![中文 README](https://img.shields.io/badge/%E4%B8%AD%E6%96%87-README-blue.svg?style=flat)](./README-zh.md)

Flix is a flexible iOS framework for creating dynamic forms with `UITableView` or `UICollectionView`.

## Features

- [x] Supports no reused when you need.
- [x] Supports reused for list when you need.
- [x] Supports nested forms.
- [x] Supports add, delete and insert
- [x] Supports Storyboard design
- [x] Example app available!
- [x] Works with `UITableView` and `UICollectionView`

Flix focus on combining cells of `UICollectionView` or `UITableView`, it don't care about the view layout, business logic. So you can easily build custom form using Flix.

## Preview

![](screenshots/example.png)

## Requirements

- Xcode 9.0+
- Swift 4.2+
- RxSwift 4.3+
- RxDataSources 3.1+

## Installation

### CocoaPods

```ruby
pod 'Flix', '~> 2.0'
```

### Carthage

```
github "DianQK/Flix" ~> 1.2
```

## Principle

![](block_diagram.png)

Each provider will generate a number of nodes (cells), then combines those providers according to the sequence.

## Tutorial - A Simple Settings Page

When creating a settings page, we don't want to some cells be reused, for example Profile Cell, Airplane Mode Cell.
This looks like creating a static tableView on Storyboard.

To create one profile cell, we just need to create a `UniqueCustomTableViewProvider` and configure the style and add some views:

<table>
  <tr>
    <td width="70%"><div class="highlight highlight-source-swift"><pre>
let profileProvider = UniqueCustomTableViewProvider()
profileProvider.itemHeight = { _ in return 80 }
profileProvider.accessoryType = .disclosureIndicator

let avatarImageView = UIImageView(
    image: #imageLiteral(resourceName: "Flix Icon")
)
profileProvider.contentView.addSubview(avatarImageView)

let nameLabel = UILabel()
nameLabel.text = "Flix"
profileProvider.contentView.addSubview(nameLabel)

let subTitleLabel = UILabel()
subTitleLabel.text = "Apple ID, iCloud, iTunes & App Store"
profileProvider.contentView.addSubview(subTitleLabel)

self.tableView.flix.build([profileProvider])
</pre></div></td>
    <th width="30%"><img src="./screenshots/tutorial_0_profile.png"></th>
  </tr>
</table>

Now, we have a profile cell for the settings page, considering we might use this provider on another `UITableView`.
We should make a Class for `profileProvider`.

We can inherit from `UniqueCustomTableViewProvider`:

```swift
class ProfileProvider: UniqueCustomTableViewProvider {

    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let subTitleLabel = UILabel()

    init(avatar: UIImage, name: String) {
        super.init()

        self.itemHeight = { _ in return 80 }
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

or just implement the protocol `UniqueAnimatableTableViewProvider`:

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

But in reality, the profile cell is placed in a section.
We can use `SectionProfiler`:

<table>
  <tr>
    <td width="70%"><div class="highlight highlight-source-swift"><pre>
let profileSectionProvider = SpacingSectionProvider(
    providers: [profileProvider],
    headerHeight: 35,
    footerHeight: 0
)
self.tableView.flix.build([profileSectionProvider])</pre></div></td>
    <th width="30%"><img src="./screenshots/tutorial_1_profile_with_section.png"></th>
  </tr>
</table>

Then add more providers:

<table>
  <tr>
    <td width="70%"><div class="highlight highlight-source-swift"><pre>
let profileProvider = ProfileProvider(
    avatar: #imageLiteral(resourceName: "Flix Icon"),
    name: "Flix")
let profileSectionProvider = SpacingSectionProvider(
    providers: [profileProvider],
    headerHeight: 35,
    footerHeight: 0)
let airplaneModeProvider = SwitchTableViewCellProvider(
    title: "Airplane Mode",
    icon: #imageLiteral(resourceName: "Airplane"),
    isOn: false)
let wifiProvider = DescriptionTableViewCellProvider(
    title: "Wi-Fi",
    icon: #imageLiteral(resourceName: "Wifi"),
    description: "Flix_5G")
let bluetoothProvider = DescriptionTableViewCellProvider(
    title: "Bluetooth",
    icon: #imageLiteral(resourceName: "Bluetooth"),
    description: "On")
let cellularProvider = DescriptionTableViewCellProvider(
    title: "Cellular",
    icon: #imageLiteral(resourceName: "Cellular"))
let hotspotProvider = DescriptionTableViewCellProvider(
    title: "Personal Hotspot",
    icon: #imageLiteral(resourceName: "Personal Hotspot"),
    description: "Off")
let carrierProvider = DescriptionTableViewCellProvider(
    title: "Carrier",
    icon: #imageLiteral(resourceName: "Carrier"),
    description: "AT&T")
let networkSectionProvider = SpacingSectionProvider(
    providers: [
        airplaneModeProvider,
        wifiProvider,
        bluetoothProvider,
        cellularProvider,
        hotspotProvider,
        carrierProvider
    ],
    headerHeight: 35,
    footerHeight: 0
)
self.tableView.flix.build(
    [profileSectionProvider, networkSectionProvider]
)
    </pre></div></td>
    <th width="30%"><img src="./screenshots/tutorial_2_more_sections.png"></th>
  </tr>
</table>

Until now, we just use one provider to generate one cell.
We can also create a provider for a group of cells.

<table>
  <tr>
    <td width="70%"><div class="highlight highlight-source-swift"><pre>
let appSectionProvider = SpacingSectionProvider(
    providers: [AppsProvider(apps: [
        App(icon: Wallet, title: "Wallet"),
        App(icon: iTunes, title: "iTunes"),
        App(icon: Music, title: "Music"),
        App(icon: Safari, title: "Safari"),
        App(icon: News, title: "News"),
        App(icon: Camera, title: "Camera"),
        App(icon: Photos), title: "Photo")
        ])],
    headerHeight: 35,
    footerHeight: 35
)
self.tableView.flix.build([
    profileSectionProvider,
    networkSectionProvider,
    appSectionProvider]
)
    </pre></div></td>
    <th width="30%"><img src="./screenshots/tutorial_3_final.png"></th>
  </tr>
</table>

Look like good.

Actually Flix supports more build list view function, you can easily create a page with all kinds of linkage effects (such as Calendar Events, GitHub Signup).
More example are available in the **Example Folder**.

## Contributing

1. Please fork this project
2. Implement new methods or changes。
3. Write appropriate docs and comments in the README.md
4. Submit a pull request.

## Contact

Raise an [Issue](https://github.com/DianQK/Flix/issues) or hit me up on Twitter [@Songxut](https://twitter.com/Songxut).

## License

Flix is released under an MIT license. See LICENSE for more information.

# Flix
iOS form builder in Swift

Flix 为 iOS 动态表单提供了足够优雅的解决方案。你可以用它构建任何(类)表单页面。(虽然足够好用，但项目仍然处于早期开发中，类名、方法名、内部实现随时都可能进行更改，导致您基于 Flix 的工程无法运行。

![](https://raw.githubusercontent.com/DianQK/Flix/master/screenshot.png)

- [x] 支持 `UICollectionView` / `UITableView`
- [x] 免去重用带来的烦恼
- [x] 列表项支持重用
- [x] 支持内嵌表单

目前提供了通过 CocoaPods 引用的方法：

```ruby
pod 'Flix', '~> 0.7.0-beta.1'
```

Flix 通过若干个 `Provider` 组合成一个列表视图。`Provider` 主要以下几种协议：

- `CollectionViewMultiNodeProvider` 支持在一个 `Provider` 中生成多种 Cell 组合
- `CollectionViewProvider` 继承 `CollectionViewMultiNodeProvider`， 生成单种 Cell 的组合
- `AnimatableCollectionViewMultiNodeProvider` 继承 `CollectionViewMultiNodeProvider` ，可以生成支持带动画的添加删除效果
- `AnimatableCollectionViewProvider` 等价于 `AnimatableCollectionViewMultiNodeProvider & CollectionViewProvider`
- `UniqueAnimatableCollectionViewProvider` 继承 `AnimatableCollectionViewProvider`，可以生成全局唯一的 Cell 以避免重用

- `SectionCollectionViewProvider` (alpha) 提供构建 Section Header & Footer 支持
- `AnimatableSectionCollectionViewProvider` (alpha)

- `TableViewMultiNodeProvider` 类似 `CollectionViewMultiNodeProvider`
- `TableViewProvider` 类似 `CollectionViewProvider`
- `AnimatableTableViewMultiNodeProvider` 类似 `AnimatableCollectionViewMultiNodeProvider`
- `AnimatableTableViewProvider` 类似 `AnimatableCollectionViewProvider`
- `UniqueAnimatableTableViewProvider` 类似 `UniqueAnimatableCollectionViewProvider`

- `SectionTableViewProvider` (alpha)
- `AnimatableSectionTableViewProvider` (alpha)

随 Flix 协议附带了以下几个类方便构建全局唯一的 Cell ：

- `UniqueCustomCollectionViewProvider`
- `UniqueCustomCollectionViewSectionProvider`
- `UniqueCustomTableViewProvider`
- `UniqueCustomTableViewSectionProvider`

你可以在 Demo 中找到以上所有协议的使用方法，这里先以 Demo 中的几个例子展示以上 Provider 的使用及其强大。

在登录示例 `LoginViewController` 中，我们直接使用了 `UniqueCustomTableViewProvider` 和 `UniqueCustomTableViewSectionProvider`。

创建用户名输入项：

```swift
let usernameProvider = UniqueCustomTableViewProvider(identity: "username")
usernameProvider.contentView.addSubview(usernameTextField)
```

`UniqueCustomTableViewProvider` 的 `contentView` 类似于 `UITableViewCell` 中的 `contentView`，你可以直接添加一个 `UITextField` 到 `UniqueCustomTableViewProvider` 中。

密码输入项也是一样的构建方式：

```swift
let passwordProvider = UniqueCustomTableViewProvider(identity: "password")
passwordProvider.contentView.addSubview(passwordTextField)
```

添加 `usernameTextField` 和 `passwordTextField` 就像在 ViewController 中直接调用 `self.view.addSubview(usernameTextField)` 和 `self.view.addSubview(passwordTextField)` 。但同时我们还拥有了 `UITableView` 的滑动效果及其 UI 样式。

为登录项添加登录验证也是如此的方便：

```
let isVerified: Observable<Bool> = Observable
    .combineLatest(
        self.usernameTextField.rx.text.orEmpty.map { !$0.isEmpty },
        self.passwordTextField.rx.text.orEmpty.map { !$0.isEmpty }
    ) { $0 && $1 }
    .share(replay: 1, scope: .forever)

isVerified
    .subscribe(onNext: { [weak self] (isVerified) in
        self?.loginTextLabel.textColor = isVerified ? UIColor.red : UIColor.lightGray
        loginProvider.selectionStyle.value = isVerified ? .default : .none
    })
    .disposed(by: disposeBag)
```

完整的 `LoginViewController` 也仅有 100 多行的代码。

`GitHubSignupViewController` 复刻了 [`GitHubSignupViewController1`](https://github.com/ReactiveX/RxSwift/blob/master/RxExample/RxExample/Examples/GitHubSignup/UsingVanillaObservables/GitHubSignupViewController1.swift) 。使用了 `GitHubSignupViewController1` 对应的 `GithubSignupViewModel1` 。UI 使用 Flix 重做后，代码量基本没有变化（除去构建 UI 部分）。

在 `DoNotDisturbSettingsViewController` 中用 `AnimatableCollectionViewProvider` 创建了 `RadioProvider` ，这是一个单选项，使用 `RadioProvider` 可以创建若干个的选择项，`RadioProvider` 生成的 Cell 都会被 `UITableView` 复用，创建足够多个选择项也不会有内存不足方面的问题。

`RadioProvider` 的实现和使用也非常方便，完整的实现如下：

```swift
struct RadioProvider<Option: Equatable & StringIdentifiableType>: AnimatableCollectionViewProvider {

    let identity: String // Hashable
    let options: [Option]
    let checkedOption = Variable<Option?>(nil)
    let disposeBag = DisposeBag()

    typealias Cell = RadioCollectionViewCell
    typealias Value = Option

    init(identity: String, options: [Option]) {
        self.identity = identity
        self.options = options
    }

    func configureCell(_ collectionView: UICollectionView, cell: RadioCollectionViewCell, indexPath: IndexPath, value: Option) {
        cell.titleLabel.text = String(describing: value)
        checkedOption.asObservable()
            .map { $0 == value }
            .bind(to: cell.isChecked)
            .disposed(by: cell.reuseBag)
    }

    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value) {
        collectionView.deselectItem(at: indexPath, animated: true)
        checkedOption.value = value
    }

    func genteralValues() -> Observable<[Value]> {
        return Observable.just(options)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: Value) -> CGSize? {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }

}
```

在使用时仅需传入对应数量的选择项：

```swift
let radioProvider = RadioProvider(identity: "radioProvider", options: [SlienceMode.always, SlienceMode.whileLocked])
radioProvider.checkedOption.value = SlienceMode.always
providers.append(radioProvider)
```

你可以在 `DoNotDisturbSettingsViewController` 和 `PhotoSettingsViewController` 中了解到更多内容。

内嵌表单示例可以参见 `NestFormViewController`。

//
//  PhotoSettingsViewController.swift
//  FormDemo
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Flix

class PhotoSettingsViewController: CollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var sectionProviders: [AnimatableCollectionViewSectionProvider] = []
        
        do {
            let icloudUploadSwitchProvider = UniqueSwitchProvider(identity: "icloudUploadSwitch")
            icloudUploadSwitchProvider.titleLabel.text = "iCloud 照片图库"
            icloudUploadSwitchProvider.uiSwitch.isOn = true
            let icloudUploadSwitchFooterProvider = TextSectionProvider(
                identity: "icloudUploadSwitchFooterProvider",
                collectionElementKindSection: UICollectionElementKindSection.footer,
                text: "您的整个图库将自动上传并储存至 iCloud，方便您在所有设备上访问照片和视频。")
            let icloudUploadSwitchSectionProvider = AnimatableCollectionViewSectionProvider(
                identity: "icloudUploadSwitchSectionProvider",
                providers: [icloudUploadSwitchProvider],
                footerProvider: icloudUploadSwitchFooterProvider
            )
            sectionProviders.append(icloudUploadSwitchSectionProvider)
        }
        
        do {
            
            enum DownloadImageType: String, CustomStringConvertible, StringIdentifiableType {
                case optimizeStorage
                case keepOriginals
                
                var identity: String {
                    return self.rawValue
                }
                
                var description: String {
                    switch self {
                    case .optimizeStorage:
                        return "优化 iPhone 储存空间"
                    case .keepOriginals:
                        return "下载并保留原件"
                    }
                }
                
                var comment: String {
                    switch self {
                    case .optimizeStorage:
                        return "如果 iPhone 的空间不足，全分辨率照片和视频将自动替换为优化版本。全分辨率版本储存在 iCloud 中。"
                    case .keepOriginals:
                        return "此 iPhone 当前正在储存原始照片和视频。打开“优化储存空间”来自动管理此设备的储存控件并将原件保留在 iCloud 中。"
                    }
                }
                
            }
            
            let selectDownloadTypeProvider = RadioProvider(
                identity: "selectDownloadTypeProvider",
                options: [DownloadImageType.optimizeStorage, DownloadImageType.keepOriginals]
            )
            selectDownloadTypeProvider.checkedOption.value = DownloadImageType.optimizeStorage
            let selectDownloadImageTypeFooterProvider = TextSectionProvider(
                identity: "selectDownloadImageTypeFooterProvider",
                collectionElementKindSection: UICollectionElementKindSection.footer,
                text: "")
            
            selectDownloadTypeProvider.checkedOption.asObservable()
                .map { option in option?.comment ?? "" }
                .bind(to: selectDownloadImageTypeFooterProvider.text)
                .disposed(by: disposeBag)
            
            let selectDownloadImageTypeSectionProvider = AnimatableCollectionViewSectionProvider(
                identity: "selectDownloadImageTypeSectionProvider",
                providers: [selectDownloadTypeProvider],
                footerProvider: selectDownloadImageTypeFooterProvider
            )
            sectionProviders.append(selectDownloadImageTypeSectionProvider)
        }
        
        let collectionViewService = AnimatableCollectionViewBuilder(
            collectionView: collectionView,
            sectionProviders: sectionProviders
        )

        self.collectionViewBuilder = collectionViewService
    }
    
}


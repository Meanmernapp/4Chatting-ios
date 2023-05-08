//
//  CustomPhotoPickerViewController.swift
//  TLPhotoPicker
//
//  Created by wade.hawk on 2017. 5. 28..
//  Copyright © 2017년 CocoaPods. All rights reserved.
//

import Foundation
import TLPhotoPicker

class CustomPhotoPickerViewController: TLPhotosPickerViewController {
    override func makeUI() {
        super.makeUI()
        self.customNavItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: nil, action: #selector(customAction))
    }
    @objc func customAction() {
        self.delegate?.photoPickerDidCancel()
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.dismissComplete()
            self?.dismissCompletion?()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func maxCheck() -> Bool {
        let imageCount = self.selectedAssets.filter{ $0.phAsset?.mediaType == .image }.count
        let videoCount = self.selectedAssets.filter{ $0.phAsset?.mediaType == .video }.count
        if imageCount == 1  || videoCount == 1 {
            return true
        }
        return false
    }
}

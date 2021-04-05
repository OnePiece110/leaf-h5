//
//  DTUpdateAvatarViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/12.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import TZImagePickerController

class DTUpdateAvatarViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTUpdateAvatarViewController()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "个人头像"
        let rightButton = addRightBarButtonItem(rightText: "更换头像")
        rightButton.dt.target(add: self, action: #selector(rightButtonClick))
        configSubViews()
    }
    
    @objc private func rightButtonClick() {
        let selectView = DTSelectView.selectView(dataSource: ["拍照","从手机相册选择","保存图片"])
        selectView.delegate = self
        selectView.alertManager?.show()
    }
    
    private func configSubViews() {
        view.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalTo(80)
            make.left.right.equalTo(0)
            make.height.equalTo(avatarImageView.snp.width)
        }
    }
    
    private var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView().dt
            .backgroundColor(APPColor.colorWhite)
            .build
        return avatarImageView
    }()

}

extension DTUpdateAvatarViewController: DTSelectViewDelegate {
    func itemClick(selectView: DTSelectView, item: String, index: IndexPath) {
        selectView.alertManager?.removeView()
        switch item {
        case "拍照":
            let imageVC = Router.presentUIImagePickerController(isCamera: true)
            imageVC.delegate = self
            break
        case "从手机相册选择":
            let albumVc = Router.presentAlbumVC()
            albumVc?.maxImagesCount = 1
            break
        default:
            debugPrint("error item")
        }
    }
}

extension DTUpdateAvatarViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.avatarImageView.image = image
        }
        
    }
    
}

extension DTUpdateAvatarViewController: TZImagePickerControllerDelegate {
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.avatarImageView.image = photos[0]
    }
}

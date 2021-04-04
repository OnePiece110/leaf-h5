//
//  DTFeedbackViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift
import TZImagePickerController
import Photos

class DTFeedbackViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTFeedbackViewController()
        return vc
    }
    
    let disposeBag = DisposeBag()
    let viewModel = DTFeedbackViewModel()
    let itemWidth = (kScreentWidth - 10 * 2 - 5 * 3) / 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubViews()
        
        contentTextView.rx.text.orEmpty.asObservable().subscribe { [weak self] (e) in
            guard let weakSelf = self else { return }
            if let s = e.element {
                if s.count > 300 {
                    weakSelf.contentTextView.deleteBackward()
                    return
                }
                weakSelf.countLabel.text = "\(s.count)/300"
            }
        }.disposed(by: disposeBag)
    }
    
    func configureSubViews() {
        self.navigationItem.title = "意见反馈"
        
        contentTextView.placeholder = "请输入问题描述"
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentTextView.backgroundColor = .clear
        contentTextView.textColor = .white
        contentTextView.font = UIFont.dt.Bold_Font(16)
        
        let textViewBgView = UIView()
        textViewBgView.backgroundColor = APPColor.color3E5E77
        textViewBgView.layer.cornerRadius = 10
        textViewBgView.layer.masksToBounds = true
        self.view.addSubview(textViewBgView)
        textViewBgView.addSubview(self.contentTextView)
        textViewBgView.addSubview(self.countLabel)
        self.view.addSubview(self.contactInformationTextField)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.contactInformationTextField)
        self.view.addSubview(self.sendButton)
        
        textViewBgView.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(240)
        }
        
        self.countLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.bottom.equalTo(-10)
            make.right.equalTo(-15)
        }
        
        self.contentTextView.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(self.countLabel.snp.top).offset(-10)
        }
        
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(textViewBgView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(itemWidth)
        }
        
        self.contactInformationTextField.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(self.collectionView.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        
        self.sendButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(self.contactInformationTextField.snp.bottom).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(50)
        }
    }
    
    @objc private func sendButtonClick() {
        DTProgress.showProgress(in: self)
        
        var signals = [Observable<Data>]()
        for item in self.viewModel.dataSource {
            if let asset = item.asset, item.url.isEmpty, item.type != .add {
                let signal = DTPHAssetsLoadingManager.default.requestImageData(asset: asset)
                signals.append(signal)
            }
        }
        if signals.count > 0 {
            Observable.zip(signals).subscribe { [weak self] (datas) in
                guard let weakSelf = self else { return }
                let imageSources = weakSelf.viewModel.dataSource.filter{ $0.type != .add}
                if datas.count == imageSources.count {
                    weakSelf.uploadItems(datas: datas)
                } else {
                    DTProgress.showError(in: weakSelf, message: "上传图片失败")
                }
            } onError: { [weak self] (err) in
                guard let weakSelf = self else { return }
                DTProgress.showError(in: weakSelf, message: "上传图片失败")
            }.disposed(by: disposeBag)
        } else {
            let (valid, text) = DTConstants.checkValidText(textView: self.contentTextView)
            if valid {
                self.feedbackAction(imgs: "imgs", text: text)
            } else {
                DTProgress.showError(in: self, message: "请输入问题描述")
            }
        }
        
    }
    
    private func uploadItems(datas: [Data]) {
        var signals = [Observable<DTUploadModel>]()
        for (index, imageData) in datas.enumerated() {
            let uploadSignal: Observable<DTUploadModel> = DTHttp.share.uploadImage(imageData) { [weak self] (json, err) in
                guard let weakSelf = self else { return }
                if let json = json {
                    weakSelf.viewModel.dataSource[index].url = json.entry
                }
            }
            signals.append(uploadSignal)
        }
        Observable.zip(signals).subscribe { [weak self] (datas) in
            guard let weakSelf = self else { return }
            let imgs = weakSelf.viewModel.dataSource.map{ $0.url }.joined(separator: ",")
            let (valid, text) = DTConstants.checkValidText(textView: weakSelf.contentTextView)
            if valid {
                weakSelf.feedbackAction(imgs: imgs, text: text)
            } else {
                DTProgress.showError(in: weakSelf, message: "请输入问题描述")
            }
            
        } onError: { [weak self] (err) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "上传图片失败")
        }.disposed(by: disposeBag)
    }
    
    private func feedbackAction(imgs: String, text: String) {
        self.viewModel.feedback(imgs: imgs, feedback: text).subscribe { (json) in
            if let status = json.status, status {
                DTProgress.showSuccess(in: self, message: "反馈成功")
                self.popSelf()
            }
        } onError: { [weak self] (err) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "反馈失败")
        }.disposed(by: disposeBag)
    }
    
    func calculateCollectionViewHeight() {
        let column = self.viewModel.dataSource.count / 4
        
        let collectionHeight = CGFloat((self.viewModel.dataSource.count % 4 > 0) ? 1 + column : column) * itemWidth + CGFloat(column * 5)
        
        self.collectionView.reloadData()
        self.collectionView.snp.updateConstraints { (make) in
            make.height.equalTo(collectionHeight)
        }
    }
    
    private lazy var contentTextView: DTTextView = {
        let contentTextView = DTTextView()
        contentTextView.backgroundColor = APPColor.colorSubBgView
        return contentTextView
    }()
    
    private lazy var countLabel:UILabel = {
        let countLabel = UILabel()
        countLabel.text = "0/300"
        countLabel.textColor = UIColor.white.withAlphaComponent(0.2)
        countLabel.font = UIFont.dt.Font(14)
        return countLabel
    }()
    
    private lazy var collectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DTFeedbackCell.self, forCellWithReuseIdentifier: "DTFeedbackCell")
        return collectionView
    }()
    
    private lazy var sendButton: DTCustomButton = {
        let sendButton = DTCustomButton(type: .custom)
        sendButton.layer.cornerRadius = 25
        sendButton.layer.masksToBounds = true
        sendButton.setTitle("提交", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonClick), for: .touchUpInside)
        return sendButton
    }()
    
    private lazy var contactInformationTextField: DTTextFieldView = DTTextFieldView(code: "联系方式", placeHolder: "QQ或电报号", corner: 10)
}

extension DTFeedbackViewController: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        let aliveSource = self.viewModel.dataSource.filter { (data) -> Bool in
            return data.type != .add
        }
        
        if aliveSource.count != self.viewModel.maxImageCount {
            self.viewModel.dataSource.removeLast()
        }
        
        for (index, photo) in photos.enumerated() {
            let model = DTFeedbackModel(image: photo, type: .image)
            if let asset = assets[index] as? PHAsset {
                model.asset = asset
            }
            self.viewModel.dataSource.append(model)
        }

        if self.viewModel.dataSource.count < self.viewModel.maxImageCount {
            self.viewModel.dataSource.append(DTFeedbackModel(image: nil, type: .add))
        }
        self.calculateCollectionViewHeight()
    }
}

extension DTFeedbackViewController: DTFeedbackCellDelegate {
    func closeButtonClick(cell: DTFeedbackCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        if let indexPath = indexPath {
            
            let aliveSource = self.viewModel.dataSource.filter { (data) -> Bool in
                return data.type != .add
            }
            if aliveSource.count == self.viewModel.maxImageCount {
                self.viewModel.dataSource.append(DTFeedbackModel(image: nil, type: .add))
            }
            self.viewModel.dataSource.remove(at: indexPath.item)
            self.calculateCollectionViewHeight()
        }
    }
}

//MARK: -- UICollectionViewDelegate
extension DTFeedbackViewController:UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.viewModel.dataSource[indexPath.row].type == .add {
            let albumVc = Router.presentAlbumVC()
            let aliveSource = self.viewModel.dataSource.filter { (data) -> Bool in
                return data.type != .add
            }
            albumVc?.maxImagesCount = self.viewModel.maxImageCount - aliveSource.count
            albumVc?.pickerDelegate = self
        } else {
            
        }
    }
}

//MARK: -- UICollectionViewDataSource
extension DTFeedbackViewController:UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DTFeedbackCell", for: indexPath) as! DTFeedbackCell
        cell.readData(self.viewModel.dataSource[indexPath.row])
        cell.delegate = self
        return cell
    }
}

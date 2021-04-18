//
//  DTFeedbackViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift
import ZLPhotoBrowser
import Photos

class DTFeedbackViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTFeedbackViewController()
        return vc
    }
    
    private let disposeBag = DisposeBag()
    private let viewModel = DTFeedbackViewModel()
    private let itemWidth = (kScreentWidth - 10 * 2 - 5 * 3) / 4
    private var contactStr = "https://t.me/joinchat/ZPJ3fZ07uZFmMjJl"
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
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        
        let textViewBgView = UIView()
        textViewBgView.backgroundColor = APPColor.color3E5E77
        textViewBgView.layer.cornerRadius = 10
        textViewBgView.layer.masksToBounds = true
        contentView.addSubview(textViewBgView)
        textViewBgView.addSubview(self.contentTextView)
        textViewBgView.addSubview(self.countLabel)
        contentView.addSubview(self.contactInformationTextField)
        contentView.addSubview(self.collectionView)
        contentView.addSubview(self.contactInformationTextField)
        contentView.addSubview(self.descLabel)
        contentView.addSubview(self.contactLabel)
        contentView.addSubview(self.sendButton)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(scrollView.snp.width)
        }
        
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
        
        self.descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(25)
            make.top.equalTo(self.contactInformationTextField.snp.bottom).offset(10)
            make.right.equalTo(-25)
        }
        
        self.contactLabel.snp.makeConstraints { (make) in
            make.left.equalTo(25)
            make.top.equalTo(self.descLabel.snp.bottom).offset(10)
            make.right.equalTo(-25)
        }
        
        self.sendButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(self.contactLabel.snp.bottom).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(50)
            make.bottom.equalTo(-20)
        }
    }
    
    @objc private func sendButtonClick() {
        DTProgress.showProgress(in: self)
        
        let (contentValid, content) = DTConstants.checkValidText(textView: self.contentTextView)
        guard contentValid else {
            DTProgress.showError(in: self, message: "请输入问题描述")
            return
        }
        let (contactValid, contact) = DTConstants.checkValidText(textField: self.contactInformationTextField.textFied)
        guard contactValid else {
            DTProgress.showError(in: self, message: "请输入联系方式")
            return
        }
        
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
                    weakSelf.uploadItems(datas: datas, content: content, contact: contact)
                } else {
                    DTProgress.showError(in: weakSelf, message: "上传图片失败")
                }
            } onError: { [weak self] (err) in
                guard let weakSelf = self else { return }
                DTProgress.showError(in: weakSelf, message: "上传图片失败")
            }.disposed(by: disposeBag)
        } else {
            self.feedbackAction(imgs: "imgs", content: content, contact: contact)
        }
        
    }
    
    private func uploadItems(datas: [Data], content: String, contact: String) {
        var signals = [Observable<DTUploadModel>]()
        for (index, imageData) in datas.enumerated() {
            let uploadSignal: Observable<DTUploadModel> = DTHttp.share.uploadImage(imageData, fileName: "\(index).png", mimeType: "image/jpeg", uploadBlock: { [weak self] (json, err) in
                guard let weakSelf = self else { return }
                if let json = json {
                    weakSelf.viewModel.dataSource[index].url = json.entry
                }
            })
            signals.append(uploadSignal)
        }
        Observable.zip(signals).subscribe { [weak self] (datas) in
            guard let weakSelf = self else { return }
            let imgs = weakSelf.viewModel.dataSource.map{ $0.url }.joined(separator: ",")
            weakSelf.feedbackAction(imgs: imgs, content: content, contact: contact)
            
        } onError: { [weak self] (err) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "上传图片失败")
        }.disposed(by: disposeBag)
    }
    
    private func feedbackAction(imgs: String, content: String, contact: String) {
        self.viewModel.feedback(imgs: imgs, feedback: content, contact: contact).subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            if let status = json.status, status {
                DTProgress.showSuccess(in: weakSelf, message: "反馈成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    weakSelf.popSelf()
                }
            }
        } onError: { [weak self] (err) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "反馈失败")
        }.disposed(by: disposeBag)
    }
    
    @objc private func contactLabelClick() {
        let contactURL = URL(string: contactStr)
        if let contactURL = contactURL, UIApplication.shared.canOpenURL(contactURL) {
            UIApplication.shared.open(contactURL, options: [:], completionHandler: nil)
        } else {
            DTProgress.showError(in: self, message: "请下载Telegram")
        }
    }
    
    func calculateCollectionViewHeight() {
        let column = self.viewModel.dataSource.count / 4
        
        let collectionHeight = CGFloat((self.viewModel.dataSource.count % 4 > 0) ? 1 + column : column) * itemWidth + CGFloat(column * 5)
        
        self.collectionView.reloadData()
        self.collectionView.snp.updateConstraints { (make) in
            make.height.equalTo(collectionHeight)
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
    
    private lazy var contentTextView: DTTextView = {
        let contentTextView = DTTextView()
        contentTextView.backgroundColor = APPColor.colorSubBgView
        contentTextView.placeholder = "请输入问题描述"
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentTextView.backgroundColor = .clear
        contentTextView.textColor = .white
        contentTextView.font = UIFont.dt.Bold_Font(16)
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
    
    private lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.text = "您也可以加入我们官方电报群，随时反馈并可了解"
        descLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        descLabel.font = UIFont.dt.Font(14)
        descLabel.numberOfLines = 2;
        return descLabel
    }()
    
    private lazy var contactLabel: UILabel = {
        let contactLabel = UILabel()
        contactLabel.text = contactStr
        contactLabel.textColor = UIColor.white
        contactLabel.font = UIFont.dt.Bold_Font(14)
        contactLabel.dt.viewTarget(add: self, action: #selector(contactLabelClick))
        return contactLabel
    }()
    
    private lazy var contactInformationTextField: DTTextFieldView = DTTextFieldView(code: "联系方式", placeHolder: "QQ或电报号", corner: 10)
}

extension DTFeedbackViewController: DTFeedbackCellDelegate {
    func closeButtonClick(cell: DTFeedbackCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        if let indexPath = indexPath {
            
            let aliveSource = self.viewModel.dataSource.filter { (data) -> Bool in
                return data.type != .add
            }
            if aliveSource.count == self.viewModel.maxImageCount {
                self.viewModel.dataSource.append(DTFeedbackModel(image: nil, type: .add, asset: nil))
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
            let assets = self.viewModel.dataSource.filter { $0.asset != nil }.map{ $0.asset! }
            
            Router.presentAlbumVC(target: self, maxSelectCount: self.viewModel.maxImageCount, assets: assets) { [weak self] (images, assets, isOriginal) in
                guard let weakSelf = self else { return }
                weakSelf.weChatMomentClick(images: images, assets: assets)
            }
        } else {
            
        }
    }
    
    func weChatMomentClick(images: [UIImage], assets: [PHAsset]) {
        
        self.viewModel.dataSource.removeAll()
        
        for (index, photo) in images.enumerated() {
            self.viewModel.dataSource.append(DTFeedbackModel(image: photo, type: .image, asset: assets[index]))
        }

        if self.viewModel.dataSource.count < self.viewModel.maxImageCount {
            self.viewModel.dataSource.append(DTFeedbackModel(image: nil, type: .add, asset: nil))
        }
        self.calculateCollectionViewHeight()
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

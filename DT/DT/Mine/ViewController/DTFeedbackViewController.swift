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

class DTFeedbackViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTFeedbackViewController()
        return vc
    }
    
    var sendButton:UIButton?
    let disposeBag = DisposeBag()
    let viewModel = DTFeedbackViewModel()
    let itemWidth = (kScreentWidth - 20 * 2 - 10 * 3) / 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubViews()
        
        contentTextView.rx.text.orEmpty.asObservable().subscribe { [weak self] (e) in
            guard let weakSelf = self else { return }
            if let sendButton = weakSelf.sendButton,let s = e.element {
                if s.count > 300 {
                    weakSelf.contentTextView.deleteBackward()
                    return
                }
                sendButton.isSelected = !s.isVaildEmpty()
                weakSelf.countLabel.text = "\(s.count)/300"
            }
        }.disposed(by: disposeBag)
    }
    
    func configureSubViews() {
        self.navigationItem.title = "意见反馈"
        let sendButton = self.addRightBarButtonItem(rightText: "发送")
        sendButton.setTitleColor(APPColor.sub, for: .selected)
        sendButton.setTitleColor(UIColor.white.withAlphaComponent(0.2), for: .normal)
        sendButton.addTarget(self, action: #selector(sendClick), for: .touchUpInside)
        self.sendButton = sendButton
        
        contentTextView.placeholder = "请输入问题描述"
        contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentTextView.backgroundColor = .clear
        contentTextView.textColor = .white
        contentTextView.font = UIFont.dt.Bold_Font(16)
        
        self.view.addSubview(self.contentTextView)
        self.view.addSubview(countLabel)
        self.view.addSubview(self.lineView)
        self.view.addSubview(self.contactInformationTextField)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.contactInfoLabel)
        self.view.addSubview(self.contactInformationTextField)
        
        self.countLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentTextView.snp.bottom).offset(2)
            make.right.equalTo(contentTextView.snp.right)
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(1)
            make.top.equalTo(self.countLabel.snp.bottom).offset(10)
        }
        
        self.contentTextView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(26)
            make.right.equalTo(-20)
            make.height.equalTo(200)
        }
        
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.lineView.snp.bottom).offset(26)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(itemWidth)
        }
        
        self.contactInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.collectionView.snp.bottom).offset(26)
            make.left.equalTo(20)
        }
        
        self.contactInformationTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contactInfoLabel)
            make.left.equalTo(self.contactInfoLabel.snp.right).offset(13)
            make.right.equalTo(-20)
            make.height.equalTo((21))
        }
        
        self.contactInfoLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.contactInfoLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.contactInformationTextField.setContentCompressionResistancePriority(.required - 1, for: .horizontal)
        self.contactInformationTextField.setContentHuggingPriority(.required - 1, for: .horizontal)
    }
    
    @objc func sendClick() {
        DTProgress.showProgress(in: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            DTProgress.showSuccess(in: self, message: "反馈成功")
            self.popSelf()
        }
    }
    
    func calculateCollectionViewHeight() {
        let column = self.viewModel.dataSource.count / 3
        
        let collectionHeight = CGFloat((self.viewModel.dataSource.count % 3 > 0) ? 1 + column : column) * itemWidth + CGFloat(column * 10)
        
        self.collectionView.reloadData()
        self.collectionView.snp.updateConstraints { (make) in
            make.height.equalTo(collectionHeight)
        }
    }
    
    lazy var contentTextView = DTTextView()
    lazy var countLabel:UILabel = {
        let countLabel = UILabel()
        countLabel.text = "0/300"
        countLabel.textColor = UIColor.white.withAlphaComponent(0.2)
        countLabel.font = UIFont.dt.Font(14)
        return countLabel
    }()
    lazy var lineView:UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return lineView
    }()
    
    lazy var collectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DTFeedbackCell.self, forCellWithReuseIdentifier: "DTFeedbackCell")
        return collectionView
    }()
    
    lazy var contactInformationTextField:UITextField = {
        let contactInformationTextField = UITextField()
        contactInformationTextField.borderStyle = .none
        contactInformationTextField.attributedPlaceholder = "QQ/邮箱/手机".font(UIFont.dt.Bold_Font(16)).color(UIColor.white.withAlphaComponent(0.2))
        contactInformationTextField.font = UIFont.dt.Bold_Font(16)
        contactInformationTextField.textColor = .white
        return contactInformationTextField
    }()
    lazy var contactInfoLabel:UILabel = {
        let contactInfoLabel = UILabel()
        contactInfoLabel.text = "联系方式"
        contactInfoLabel.textColor = .white
        contactInfoLabel.font = UIFont.dt.Bold_Font(16)
        return contactInfoLabel
    }()
}

extension DTFeedbackViewController: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        let aliveSource = self.viewModel.dataSource.filter { (data) -> Bool in
            return data.type != .add
        }
        
        if aliveSource.count != self.viewModel.maxImageCount {
            self.viewModel.dataSource.removeLast()
        }
        
        for photo in photos {
            self.viewModel.dataSource.append(DTFeedbackModel(image: photo, type: .image))
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

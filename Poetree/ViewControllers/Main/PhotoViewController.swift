//
//  PhotoViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/26.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import NSObject_Rx
import Toast_Swift
import Firebase

class PhotoViewController: UIViewController, HasDisposeBag, StoryboardBased, ViewModelBindable {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var firstNoticeLabel: UILabel!
    @IBOutlet weak var secondNoticeLabel: UILabel!
    
    
    var viewModel: PhotoViewModel!
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        naviBarConfig()
        noticeLabelAni()
        guard let selectedIndexPath = selectedIndexPath else {return}
        self.photoCollectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func naviBarConfig(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor.link
    }
    
    func configureUI(){
        collectionViewDelegate()
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func setBarBtnItem() {
        let image = UIImage(systemName: "person.fill")
        image?.withTintColor(UIColor.systemBlue)
        let loginBtn = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(login))
        self.navigationItem.rightBarButtonItem = loginBtn
    }
    
    func bindViewModel() {
        
        self.viewModel.output.thisWeekPhoto
            .bind(to: photoCollectionView.rx.items(cellIdentifier: "PhotoViewCell", cellType: PhotoViewCollectionViewCell.self)){ index, photo, cell in
                cell.imageView.kf.setImage(with: photo.url)
            }
            .disposed(by: rx.disposeBag)
        
        
        photoCollectionView.rx.modelSelected(WeekPhoto.self)
            .subscribe(onNext:{[weak self] weekPhoto in
                
                guard let self = self else {return}
                
                guard let _ = Auth.auth().currentUser else { self.handleWrite()
                    return }
                
                let viewModel = WriteViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, writingType: .write(weekPhoto), isFromMain: true)
  
                var vc = WritingViewController.instantiate(storyboardID: "WritingRelated")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            })
            .disposed(by: rx.disposeBag)
        
        
    }
    
    func noticeLabelAni(){
        
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
            self.firstNoticeLabel.alpha = 1
        } completion: { firstNoticeFadeIn in
            
            if firstNoticeFadeIn {
                UIView.animate(withDuration: 1.5, delay: 1, options: .curveEaseIn) {
                    self.firstNoticeLabel.alpha = 0
                } completion: { firstNoticeFadeout in
                    
                    if firstNoticeFadeout {
                        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
                            self.secondNoticeLabel.alpha = 1
                            
                        } completion: { SecondNoticefadein in
                            if SecondNoticefadein {
                                UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
                                    self.secondNoticeLabel.alpha = 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func collectionViewDelegate() {
        
        photoCollectionView.decelerationRate = .fast
        photoCollectionView.isPagingEnabled = false
        photoCollectionView.delegate = self
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: photoCollectionView.frame.size.height)
        flowlayout.minimumInteritemSpacing = 20
        flowlayout.minimumLineSpacing = 20
        flowlayout.scrollDirection = .horizontal
        photoCollectionView.collectionViewLayout = flowlayout
    }
    
    func handleWrite(){
        
        var style = ToastStyle()
        style.messageAlignment = .center
        style.titleAlignment = .center
        style.messageFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 10)!
        style.messageFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)!
        
        self.view.makeToast("오른쪽 상단의 로그인 버튼을 확인해주세요", duration: 2, position: .center, title: "글을 쓰기 위해서는 로그인이 필요합니다", style: style){ bool in
            self.setBarBtnItem()
        }
 
    }
    
    @objc func login(){
        let viewModel = UserRegisterViewModel(userService: self.viewModel.userService)
        var vc = UserRegisterViewController.instantiate(storyboardID: "UserRelated")
        vc.bind(viewModel: viewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard let layout = self.photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            
            let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
            
            let estimatedIndex = scrollView.contentOffset.x / cellWidthIncludingSpacing
            let index: Int
            if velocity.x > 0 {
                index = Int(ceil(estimatedIndex))
            } else if velocity.x < 0 {
                index = Int(floor(estimatedIndex))
            } else {
                index = Int(round(estimatedIndex))
            }
            
            targetContentOffset.pointee = CGPoint(x: CGFloat(index) * cellWidthIncludingSpacing, y: 0)
        }
}

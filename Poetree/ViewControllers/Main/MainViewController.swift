//
//  MainViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/09.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources
import Kingfisher
import Firebase

class MainViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag{
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var poemTableView: UITableView!
    @IBOutlet weak var writeBtn: UIBarButtonItem!
    @IBOutlet weak var writeChev: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoNumberLabel: UILabel!
    @IBOutlet weak var poemForPhotoNumberLabel: UIButton!
    @IBOutlet weak var thisWeekPoemBtn: UIButton!
    @IBOutlet weak var rightChev: UIButton!
    @IBOutlet weak var leftChev: UIButton!
    
    
    
    var viewModel: MainViewModel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        collectionViewAni()
        collectionViewDelegate()
        
    }
    
    
    func collectionViewAni() {
        collectionView.alpha = 0
        UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseIn) { [unowned self] in
            self.collectionView.alpha = 1
        }
    }
    
    func collectionViewDelegate() {
        
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        collectionView.delegate = self
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: collectionView.frame.size.height)
        flowlayout.minimumInteritemSpacing = 20
        flowlayout.minimumLineSpacing = 20
        flowlayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowlayout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        resetDate()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
    }
    func resetDate() {
        viewModel.output.currentDate
            .drive(dateLabel.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    private func configureUI() {
        configureNavTab()
        thisWeekPoemBtn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        thisWeekPoemBtn.layer.cornerRadius = 3
    }
    
    private func configureNavTab() {
        
        self.navigationItem.title = "Poetree"
        self.navigationItem.largeTitleDisplayMode = .always
        self.tabBarItem.image = UIImage(systemName: "pencil")
        self.tabBarItem.selectedImage = UIImage(systemName: "pencil")
        self.tabBarItem.title = "This Week"
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }
 
    
    func bindViewModel() {
        
        viewModel.output.currentDate
            .drive(dateLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.output.thisWeekPhotoURL
            .bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: MainPhotoCollectionViewCell.self)) { index, photo, cell in
                let url = photo.url
                cell.todayImage.kf.setImage(with: url)
               
            }
            .disposed(by: rx.disposeBag)
        
        writeBtn.rx.tap
            .subscribe(onNext:{ _ in
                let viewModel = PhotoViewModel(userService: self.viewModel.userService, poemService: self.viewModel.poemService, photoService: self.viewModel.photoService)
                var photoVC = PhotoViewController.instantiate(storyboardID: "Main")
                photoVC.selectedIndexPath = self.collectionView.indexPathsForVisibleItems.first ?? IndexPath(item: 0, section: 0)
                photoVC.bind(viewModel: viewModel)
                photoVC.modalTransitionStyle = .crossDissolve
                photoVC.modalPresentationStyle = .overFullScreen
                self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
                self.navigationController?.pushViewController(photoVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext:{ indexPath in
                let viewModel = PhotoViewModel(userService: self.viewModel.userService, poemService: self.viewModel.poemService, photoService: self.viewModel.photoService)
                var photoVC = PhotoViewController.instantiate(storyboardID: "Main")
                photoVC.selectedIndexPath = indexPath
                photoVC.bind(viewModel: viewModel)
                photoVC.modalTransitionStyle = .crossDissolve
                photoVC.modalPresentationStyle = .overFullScreen
                self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
                self.navigationController?.pushViewController(photoVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        
        collectionView.rx.willDisplayCell

            .subscribe(onNext:{[unowned self] cell in

                let index = cell.at.item
                if index == 0 {
                    self.photoNumberLabel.text = "#1"
                    self.poemForPhotoNumberLabel.setTitle("#1 사진에 쓴 글", for: .normal)
                    self.viewModel.input.selectedIndex.onNext(index)
                    self.rightChev.isHidden = false
                    self.leftChev.isHidden = true
                } else if index == 2 {
                    self.rightChev.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        collectionView.rx.didEndDecelerating
            .subscribe(onNext:{[unowned self] _ in
                
                let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                let visibleItemNumber = self.collectionView.indexPathForItem(at: visiblePoint)?.item
                self.photoNumberLabel.text = "#\(visibleItemNumber! + 1)"
                self.poemForPhotoNumberLabel.setTitle("#\(visibleItemNumber! + 1) 사진에 쓴 글", for: .normal)
                self.viewModel.input.selectedIndex.onNext(visibleItemNumber!)
                if visibleItemNumber == 1 {
                    leftChev.isHidden = false
                    rightChev.isHidden = false
                } else if visibleItemNumber == 0 {
                    leftChev.isHidden = true
                    rightChev.isHidden = false
                } else {
                    leftChev.isHidden = false
                    rightChev.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.output.displayingPoems
            .bind(to: poemTableView.rx.items(cellIdentifier: "poemCell", cellType: MainPoemTableViewCell.self)){ index, poem, cell in
                cell.titleLabel.text = poem.title
                cell.authorLabel.text = "by. \(poem.userPenname)"
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                if index == 0 {
                    cell.favoriteBtn.isHidden = false
                    cell.favoriteBtn.layer.cornerRadius = 8
                    cell.favoriteBtn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 4, right: 2)
                } else {
                    cell.likeCountStackView.isHidden = false
                    cell.likesCountLabel.text = "\(poem.likers.count)"
                }
                
            }
            .disposed(by: rx.disposeBag)
        
        
        thisWeekPoemBtn.rx.tap
            .subscribe(onNext:{[unowned self]_ in
                
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, listType: .thisWeek)
                var vc = PoemListViewController.instantiate(storyboardID: "ListRelated")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        
        self.poemTableView.rx.itemSelected
            .withLatestFrom(self.viewModel.output.selectedPhotoId)
            .subscribe(onNext:{ id in
                
                let viewModel = HeadPhotoWithListViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, photoService: self.viewModel.photoService, selectedPhotoId: id)
                
                var headPhotoListVC = ListWithHeadPhotoViewController.instantiate(storyboardID: "ListRelated")
                headPhotoListVC.bind(viewModel: viewModel)
                
                self.present(headPhotoListVC, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        self.rightChev.rx.tap
            .subscribe(onNext:{ _ in
                
                guard let currentIndexPathItem =  self.collectionView.indexPathsForVisibleItems.first?.item else {return}
                let next = IndexPath(item: currentIndexPathItem + 1, section: 0)
                self.collectionView.scrollToItem(at: next, at: .centeredHorizontally, animated: true)
                
                switch currentIndexPathItem {
                
                case 0:
                    self.photoNumberLabel.text = "#\(currentIndexPathItem + 2)"
                    self.poemForPhotoNumberLabel.setTitle("#\(currentIndexPathItem + 2) 사진에 쓴 글", for: .normal)
                    self.leftChev.isHidden = false
                case 1:
                    self.photoNumberLabel.text = "#\(currentIndexPathItem + 2)"
                    self.poemForPhotoNumberLabel.setTitle("#\(currentIndexPathItem + 2) 사진에 쓴 글", for: .normal)
                    self.rightChev.isHidden = true
                    self.leftChev.isHidden = false
                default:
                    break
                }
                
                self.viewModel.input.selectedIndex.onNext(currentIndexPathItem + 1)
                
            })
            .disposed(by: rx.disposeBag)
        
        self.leftChev.rx.tap
            .subscribe(onNext:{ _ in
                
                guard let currentIndexPathItem =  self.collectionView.indexPathsForVisibleItems.first?.item else {return}
                
                let next = IndexPath(item: currentIndexPathItem - 1, section: 0)

                self.collectionView.scrollToItem(at: next, at: .centeredHorizontally, animated: true)
                
                
                self.photoNumberLabel.text = "#\(currentIndexPathItem)"
                self.poemForPhotoNumberLabel.setTitle("#\(currentIndexPathItem ) 사진에 쓴 글", for: .normal)
                
                
                if currentIndexPathItem == 1 {
                    self.leftChev.isHidden = true
                    self.rightChev.isHidden = false
                } else if currentIndexPathItem == 2 {
                    self.rightChev.isHidden = false
                }

                
                self.viewModel.input.selectedIndex.onNext(currentIndexPathItem - 1)
                
                
            })
            .disposed(by: rx.disposeBag)
    }
}


extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
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

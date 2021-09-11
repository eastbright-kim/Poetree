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
                photoVC.bind(viewModel: viewModel)
                photoVC.selectedIndexPath = IndexPath(item: 0, section: 0)
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
                photoVC.bind(viewModel: viewModel)
                photoVC.selectedIndexPath = indexPath
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
                    print("will display cell called")
                    self.photoNumberLabel.text = "#1"
                    self.poemForPhotoNumberLabel.setTitle("#1 사진에 쓴 글", for: .normal)
                    self.viewModel.input.selectedIndex.onNext(index)
                  
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
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.output.displayingPoems
            .bind(to: poemTableView.rx.items(cellIdentifier: "poemCell", cellType: MainPoemTableViewCell.self)){ index, poem, cell in
                cell.titleLabel.text = poem.title
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
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

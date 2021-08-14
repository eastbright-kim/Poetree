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

class MainViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag{
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var thisWeekPoemBtn: UIButton!
    @IBOutlet weak var writePoemBtn: UIButton!
    @IBOutlet weak var poemTableView: UITableView!
    @IBOutlet weak var logInBtn: UIBarButtonItem!
    @IBOutlet weak var writeChev: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel: MainViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        collectionViewAni()
        collectionViewDelegate()
    }
    
    func collectionViewAni() {
        collectionView.alpha = 0
        UIView.animate(withDuration: 2, delay: 1, options: .curveEaseIn) { [unowned self] in
            self.collectionView.alpha = 1
        }
    }
    
    func collectionViewDelegate() {
        
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        collectionView.delegate = self
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.size.height)
        flowlayout.minimumInteritemSpacing = 0
        flowlayout.minimumLineSpacing = 0
        flowlayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowlayout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        resetDate()
        
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
        
        
        collectionView.rx.modelSelected(WeekPhoto.self)
            .subscribe(onNext:{[unowned self] weekPhoto in
                
                print(weekPhoto.url)
                
                let viewModel = WritePoemViewModel(weekPhoto: weekPhoto, poemService: self.viewModel.poemService)
                
                var vc = WritingViewController.instantiate(storyboardID: "Main")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
                
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

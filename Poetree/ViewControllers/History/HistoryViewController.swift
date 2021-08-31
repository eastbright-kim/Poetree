//
//  HistoryViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Kingfisher

class HistoryViewController: UIViewController, ViewModelBindable, StoryboardBased, UICollectionViewDelegate {

    
    @IBOutlet weak var allPoemsBtn: UIButton!
    
    @IBOutlet weak var LastWeekPhotoCollectionView: UICollectionView!
    @IBOutlet weak var AllPhotoCollectionView: UICollectionView!
    
    
    
    var viewModel: HistoryViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        collectionViewDelegate()
    }
    
    func collectionViewDelegate() {
        
        AllPhotoCollectionView.decelerationRate = .fast
        AllPhotoCollectionView.isPagingEnabled = false
        AllPhotoCollectionView.delegate = self
        LastWeekPhotoCollectionView.delegate = self
        LastWeekPhotoCollectionView.decelerationRate = .fast
        LastWeekPhotoCollectionView.isPagingEnabled = false
//        LastWeekPhotoCollectionView.decelerationRate = .fast
//        LastWeekPhotoCollectionView.isPagingEnabled = false
//        LastWeekPhotoCollectionView.delegate = self
        
//        let flowlayout = UICollectionViewFlowLayout()
//        flowlayout.itemSize = CGSize(width: 100, height: 100 * 10 / 7)
//        flowlayout.minimumInteritemSpacing = 10
//        flowlayout.minimumLineSpacing = 10
//        flowlayout.scrollDirection = .horizontal
//        AllPhotoCollectionView.collectionViewLayout = flowlayout
//        LastWeekPhotoCollectionView.collectionViewLayout = flowlayout
    }
    
    private func configureUI() {
        
        configureNavTab()
        allPoemsBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        allPoemsBtn.layer.cornerRadius = 8
    }
    
    private func configureNavTab() {
        self.navigationItem.title = "History"
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.tabBarItem.image = UIImage(systemName: "book.fill")
        self.tabBarItem.selectedImage = UIImage(systemName: "book.fill")
        self.tabBarItem.title = "History"
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }
    
    
    func bindViewModel() {
        
      
        viewModel.output.allPhotos
            .bind(to:
                    AllPhotoCollectionView.rx.items(cellIdentifier: "AllPhotoCell", cellType: HistoryPhotoCollectionViewCell.self)){indexPath, photo, cell in
                print("all photo \(self.viewModel.photoService.photos())")
                print("all photo id \(photo.id)")

                cell.photoImageView.kf.setImage(with: photo.url)
            }
            .disposed(by: rx.disposeBag)
        
       
        
        allPoemsBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemSevice, listType: .allPoems)
                var vc = PoemListViewController.instantiate(storyboardID: "ListRelated")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        
        
    }
}


extension HistoryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heigt = collectionView.frame.height
        let width = CGFloat(100)
        return CGSize(width: 100, height: 100 * 10 / 7)
    }
}

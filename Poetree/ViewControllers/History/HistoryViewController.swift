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
    @IBOutlet weak var lastWeekPhotoCollectionView: UICollectionView!
    @IBOutlet weak var allPhotoCollectionView: UICollectionView!
    @IBOutlet weak var threePoemsTableView: UITableView!
    @IBOutlet weak var indexCountLabel: UIButton!
    
    
    
    var viewModel: HistoryViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        collectionViewDelegate()
    }
    
    
    func collectionViewDelegate() {
        
        allPhotoCollectionView.decelerationRate = .fast
        allPhotoCollectionView.isPagingEnabled = false
        allPhotoCollectionView.delegate = self
        lastWeekPhotoCollectionView.delegate = self
        lastWeekPhotoCollectionView.decelerationRate = .fast
        lastWeekPhotoCollectionView.isPagingEnabled = false
        
        
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: 100, height: 100 * 10 / 7)
        flowlayout.minimumInteritemSpacing = 28
        flowlayout.minimumLineSpacing = 28
        flowlayout.scrollDirection = .horizontal
        
        let totalCellWidth = 100 * 3
        let totalSpacingWidth = 30 * 2
        
        let leftInset = (lastWeekPhotoCollectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        let inset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        flowlayout.sectionInset = inset
        
        lastWeekPhotoCollectionView.collectionViewLayout = flowlayout
    }
    
    private func configureUI() {
        self.threePoemsTableView.delegate = self
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
                    allPhotoCollectionView.rx.items(cellIdentifier: "AllPhotoCell", cellType: HistoryPhotoCollectionViewCell.self)){indexPath, photo, cell in
                print("all photo \(self.viewModel.photoService.photos())")
                print("all photo id \(photo.id)")

                cell.photoImageView.kf.setImage(with: photo.url)
            }
            .disposed(by: rx.disposeBag)
        
       
        
        allPoemsBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemSevice, userService: self.viewModel.userService, listType: .allPoems)
                var vc = PoemListViewController.instantiate(storyboardID: "ListRelated")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.output.lastWeekPhotos
            .bind(to: lastWeekPhotoCollectionView.rx.items(cellIdentifier: "LastWeekPhotoCell", cellType: LastWeekPhotoCollectionViewCell.self)){indexPath, photos, cell in
                cell.lastWeekPhotoImageView.kf.setImage(with: photos.url)
            }
            .disposed(by: rx.disposeBag)
        
        lastWeekPhotoCollectionView.rx.itemSelected
            .subscribe(onNext:{ index in
                print(index.section)
                print(index.item)
                print("\(index) indexPath")
                self.indexCountLabel.setTitle("Wrtings for #\(index.item + 1)", for: .normal)
            })
            .disposed(by: rx.disposeBag)
        
        lastWeekPhotoCollectionView.rx.modelSelected(WeekPhoto.self)
            .bind(to: viewModel.input.photoSelected)
            .disposed(by: rx.disposeBag)
        
        allPhotoCollectionView.rx.modelSelected(WeekPhoto.self)
            .subscribe(onNext:{ weekPhoto in
                
                let viewModel = HeadPhotoWithListViewModel(poemService: self.viewModel.poemSevice, userService: self.viewModel.userService, photoService: self.viewModel.photoService, selectedPhotoId: weekPhoto.id)
                
                
                var headPhotoListVC = ListWithHeadPhotoViewController.instantiate(storyboardID: "ListRelated")
                headPhotoListVC.bind(viewModel: viewModel)
                
                self.navigationController?.pushViewController(headPhotoListVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.viewModel.output.displayingPoems
            .bind(to: self.threePoemsTableView.rx.items(cellIdentifier: "ThreePoemsTableViewCell", cellType: ThreePoemsTableViewCell.self)){indexPath, poem, cell in
                
                switch indexPath {
                case 0:
                    cell.prizeImage.image = UIImage(named: "gold-medal")
                case 1:
                    cell.prizeImage.image = UIImage(named: "silver-medal")
                default:
                    cell.prizeImage.image = UIImage(named: "bronze-medal")
                }
                
                cell.titleLabel.text = poem.title
                cell.authorLabel.text = "by. \(poem.userPenname)"
            }
            .disposed(by: rx.disposeBag)
    }
}


extension HistoryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100 * 10 / 7)
    }
}

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.threePoemsTableView.frame.height) / 3
    }
    
}

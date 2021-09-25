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
    @IBOutlet var imageArr: [UIImageView]!
    @IBOutlet var imageViewArr: [UIView]!
    @IBOutlet weak var image1Btn: UIButton!
    @IBOutlet weak var image2Btn: UIButton!
    @IBOutlet weak var image3Btn: UIButton!
    @IBOutlet weak var allPhotoCollectionView: UICollectionView!
    @IBOutlet weak var threePoemsTableView: UITableView!
    @IBOutlet weak var indexCountLabel: UIButton!
    
    var viewModel: HistoryViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        collectionViewDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        naviBarConfig()
    }
    
    func naviBarConfig(){
        self.navigationController?.navigationBar.tintColor = UIColor.label
        self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func collectionViewDelegate() {
        
        allPhotoCollectionView.decelerationRate = .fast
        allPhotoCollectionView.isPagingEnabled = false
        allPhotoCollectionView.delegate = self
        
        let flowlayoutForLastWeekPhotos = UICollectionViewFlowLayout()
        flowlayoutForLastWeekPhotos.itemSize = CGSize(width: 100, height: 100 * 10 / 7)
        flowlayoutForLastWeekPhotos.minimumInteritemSpacing = 28
        flowlayoutForLastWeekPhotos.minimumLineSpacing = 28
        flowlayoutForLastWeekPhotos.scrollDirection = .horizontal
        
        let flowlayoutForAllPhotos = UICollectionViewFlowLayout()
        flowlayoutForAllPhotos.itemSize = CGSize(width: 100, height: 100 * 10 / 7)
        flowlayoutForAllPhotos.minimumInteritemSpacing = 15
        flowlayoutForAllPhotos.minimumLineSpacing = 15
        flowlayoutForAllPhotos.scrollDirection = .horizontal
        
        allPhotoCollectionView.collectionViewLayout = flowlayoutForAllPhotos
    }
    
    private func configureUI() {
        threePoemsTableView.tableFooterView = UIView()
        self.threePoemsTableView.delegate = self
        configureNavTab()
        allPoemsBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        allPoemsBtn.layer.cornerRadius = 8

        for i in 0...2 {
            makePhotoViewShadowForHistory(superView: self.imageViewArr[i], photoImageView: self.imageArr[i])
        }
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
        
      
        viewModel.output.displayingPhoto
            .bind(to:
                    allPhotoCollectionView.rx.items(cellIdentifier: "AllPhotoCell", cellType: HistoryPhotoCollectionViewCell.self)){indexPath, photo, cell in
                cell.photoImageView.kf.setImage(with: photo.url)
            }
            .disposed(by: rx.disposeBag)
        
        image1Btn.rx.tap
            .subscribe(onNext:{ _ in
                self.viewModel.input.indexSelected.onNext(0)
            })
            .disposed(by: rx.disposeBag)
        
        image2Btn.rx.tap
            .subscribe(onNext:{ _ in
                self.viewModel.input.indexSelected.onNext(1)
            })
            .disposed(by: rx.disposeBag)
        
        image3Btn.rx.tap
            .subscribe(onNext:{ _ in
                self.viewModel.input.indexSelected.onNext(2)
            })
            .disposed(by: rx.disposeBag)
        
        allPoemsBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                
                guard let self = self else {return}
                
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemSevice, userService: self.viewModel.userService, listType: .allPoems)
                var vc = PoemListViewController.instantiate(storyboardID: "ListRelated")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        
        threePoemsTableView.rx.modelSelected(Poem.self)
            .subscribe(onNext: { poem in
                
                let viewModel = SemiDetailViewModel(poem: poem, poemService: self.viewModel.poemSevice, userService: self.viewModel.userService)
                
                var semiDetailVC = SemiDetailViewController.instantiate(storyboardID: "WritingRelated")
                
                semiDetailVC.bind(viewModel: viewModel)
                semiDetailVC.modalTransitionStyle = .crossDissolve
                semiDetailVC.modalPresentationStyle = .custom
                
                self.present(semiDetailVC, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.output.printedIndex
            .drive(onNext: { index in
                self.indexCountLabel.setTitle("Writings for #\(index)", for: .normal)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.output.lastWeekPhotos
            .bind(onNext:{ weekPhotos in
                
                if weekPhotos.count < 3 {
                    
                    for i in 0...2 {
                        self.imageArr[i].kf.setImage(with: whites[i].url)
                    }
                } else if weekPhotos.count == 3 {
                    for i in 0...2 {
                        self.imageArr[i].kf.setImage(with: weekPhotos[i].url)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        allPhotoCollectionView.rx.modelSelected(WeekPhoto.self)
            .subscribe(onNext:{ weekPhoto in
                
                let viewModel = HeadPhotoWithListViewModel(poemService: self.viewModel.poemSevice, userService: self.viewModel.userService, photoService: self.viewModel.photoService, selectedPhotoId: weekPhoto.id)
                
                var headPhotoListVC = ListWithHeadPhotoViewController.instantiate(storyboardID: "ListRelated")
                headPhotoListVC.bind(viewModel: viewModel)
                
                self.navigationController?.pushViewController(headPhotoListVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.viewModel.output.displyingPoemsByPhoto
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
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
}


extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.threePoemsTableView.frame.height) / 3
    }
    
}

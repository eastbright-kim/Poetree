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

class HistoryViewController: UIViewController, ViewModelBindable, StoryboardBased {

    
    @IBOutlet weak var allPoemsBtn: UIButton!
    @IBOutlet weak var lastWeekPoemTableView: UITableView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var viewModel: HistoryViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
        
        viewModel.output.lastWeekPoems
            .bind(to: lastWeekPoemTableView.rx.items(cellIdentifier: "lastWeekCell", cellType: PoemListTableViewCell.self)){ indexPath, poem, cell in
                
                cell.poemImageView.kf.setImage(with: poem.photoURL)
                cell.titleLabel.text = poem.title
                cell.userLabel.text = poem.userPenname
                
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.output.allPhotos
            .bind(to: photoCollectionView.rx.items(cellIdentifier: "HistoryPhotoCollectionViewCell", cellType: HistoryPhotoCollectionViewCell.self)){indexPath, photo, cell in
                
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
        return CGSize(width: width, height: heigt)
    }
    
    
}

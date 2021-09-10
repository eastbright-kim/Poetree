//
//  ListWithHeadPhotoViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/09.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import NSObject_Rx

class ListWithHeadPhotoViewController: UIViewController, ViewModelBindable, HasDisposeBag, StoryboardBased {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var poemListTableView: UITableView!
    @IBOutlet weak var XMarkBtn: UIButton!
    
    
    var viewModel: HeadPhotoWithListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    func bindViewModel() {
        
        viewModel.output.displayingPoem
            .bind(to: self.poemListTableView.rx.items(cellIdentifier: "headPhotoListTableViewCell", cellType: headPhotoListTableViewCell.self)){ indexPath, poem, cell in
                
                cell.authorLabel.text = poem.userPenname
                cell.titleLabel.text = poem.title
                cell.contentLabel.text = poem.content
                
                if indexPath <= 3{
                    cell.likesLabel.text = "\(poem.likers.count)"
                }
            }
            .disposed(by: rx.disposeBag)
        
        
        
        self.poemListTableView.rx.itemSelected
            .subscribe(onNext:{ indexPath in
                self.poemListTableView.cellForRow(at: indexPath)?.isSelected = false
            })
            .disposed(by: rx.disposeBag)
        
        self.poemListTableView.rx.modelSelected(Poem.self)
            .subscribe(onNext:{ poem in
                
                let viewModel = SemiDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                
                var semiDetailVC = SemiDetailViewController.instantiate(storyboardID: "WritingRelated")
                semiDetailVC.bind(viewModel: viewModel)
                
                semiDetailVC.modalTransitionStyle = .crossDissolve
                semiDetailVC.modalPresentationStyle = .overCurrentContext
                
                self.present(semiDetailVC, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
        
        
        self.XMarkBtn.rx.tap
            .subscribe(onNext:{ _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureUI(){
        
        photoImageView.layer.cornerRadius = 8
        
        
        if Auth.auth().currentUser != nil {
            let image = UIImage(systemName: "pencil")
            image?.withTintColor(UIColor.darkGray)
            let writeItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(write))
            self.navigationItem.rightBarButtonItem = writeItem
        }
        
        if let weekPhoto = self.viewModel.output.weekPhoto {
            self.photoImageView.kf.setImage(with: weekPhoto.url)
        }
        
    }
    
    @objc func write(){
        
    }
}

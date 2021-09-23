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
    @IBOutlet weak var backScrollView: UIScrollView!
    
    var viewModel: HeadPhotoWithListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        initRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        naviBarConfig()
    }
    
    func naviBarConfig(){
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.label
    }
    
    private func initRefresh() {
        backScrollView.refreshControl = UIRefreshControl()
        backScrollView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        self.viewModel.poemService.fetchPoems { complete in
            DispatchQueue.main.async {
                self.backScrollView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func bindViewModel() {
        
        viewModel.output.displayingPoem
            .bind(to: self.poemListTableView.rx.items(cellIdentifier: "headPhotoListTableViewCell", cellType: headPhotoListTableViewCell.self)){ indexPath, poem, cell in
                cell.authorLabel.text = "by. \(poem.userPenname)"
                cell.titleLabel.text = poem.title
                cell.contentLabel.text = poem.content
                cell.likesLabel.text = "\(poem.likers.count)"
                cell.selectionStyle = .none
                cell.heartStackView.isHidden = (indexPath > 2)
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
                semiDetailVC.modalPresentationStyle = .custom
                
                self.present(semiDetailVC, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
        self.viewModel.output.selectedPhoto
            .subscribe(onNext:{ weekPhoto in
                self.photoImageView.kf.setImage(with: weekPhoto.url)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureUI(){
        
        photoImageView.layer.cornerRadius = 8
        navigationItem.largeTitleDisplayMode = .never
        poemListTableView.tableFooterView = UIView()
        
        if Auth.auth().currentUser != nil {
            let image = UIImage(systemName: "pencil")
            image?.withTintColor(UIColor.darkGray)
            let writeItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(write))
            self.navigationItem.rightBarButtonItem = writeItem
        }
        
    }
    
    @objc func write(){
        
        self.viewModel.output.selectedPhoto
            .take(1)
            .subscribe(onNext:{ weekPhoto in
                let viewModel = WriteViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, writingType: .write(weekPhoto))
                
                var writeVC = WritingViewController.instantiate(storyboardID: "WritingRelated")
                writeVC.bind(viewModel: viewModel)
                
                let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                backBarButtonItem.tintColor = .systemOrange
                self.navigationItem.backBarButtonItem = backBarButtonItem
                
                self.navigationController?.pushViewController(writeVC, animated: true)
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
    
}

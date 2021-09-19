//
//  WritingListViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Kingfisher

class PoemListViewController: UIViewController, StoryboardBased, ViewModelBindable, HasDisposeBag {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: PoemListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
    }
    
    private func initRefresh() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        self.viewModel.poemService.fetchPoems { complete in
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func configureUI(){
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let type = self.viewModel.output.listType
        var title: String?
        switch type {
        case .allPoems:
            title = "모든 글"
        case .thisWeek:
            title = "이번 주 글"
        case .userLiked:
            title = "좋아한 글"
        case .userWrote:
            title = "쓴 글"
        case .tempSaved:
            title = "보관한 글"
        }
        self.title = title ?? "글 목록"
        tableView.tableFooterView = UIView()
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorInset.left = 20
        tableView.separatorInset.right = 20
    }
    
    func bindViewModel() {
        
        viewModel.output.displayingPoems
            .bind(to: tableView.rx.items(cellIdentifier: "PoemListCell", cellType: PoemListTableViewCell.self)) { row, poem, cell in
                
                let type = self.viewModel.output.listType
                
                switch type {
                case .allPoems, .thisWeek, .userWrote:
                    cell.poemImageView.kf.setImage(with: poem.photoURL)
                    cell.contentLabel.text = poem.content
                    cell.titleLabel.text = poem.title
                    cell.likesLabel.text = "\(poem.likers.count)"
                    cell.userLabel.text = "by .\(poem.userPenname)"
                    cell.likesStackView.isHidden = (row > 2)
                case .userLiked:
                    cell.contentLabel.text = poem.content
                    cell.poemImageView.kf.setImage(with: poem.photoURL)
                    cell.titleLabel.text = poem.title
                    cell.likesLabel.text = "\(poem.likers.count)"
                    cell.userLabel.text = "by. \(poem.userPenname)"
                case .tempSaved:
                    cell.contentLabel.text = poem.content
                    cell.poemImageView.kf.setImage(with: poem.photoURL)
                    cell.titleLabel.text = poem.title
                    cell.likesLabel.text = "\(poem.likers.count)"
                    cell.userLabel.text = "by. \(poem.userPenname)"
                    cell.likesStackView.isHidden = true
                }
                cell.selectionStyle = .none
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(Poem.self)
            .subscribe(onNext:{[weak self] poem in
                guard let self = self else {return}
                
                let viewModel = SemiDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                var semiDetailVC = SemiDetailViewController.instantiate(storyboardID: "WritingRelated")
                semiDetailVC.bind(viewModel: viewModel)
                semiDetailVC.modalTransitionStyle = .crossDissolve
                semiDetailVC.modalPresentationStyle = .custom
                self.present(semiDetailVC, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }
}

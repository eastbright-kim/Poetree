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

    }
    
    
    func bindViewModel() {
        
        viewModel.output.displayingPoems
            .bind(to: tableView.rx.items(cellIdentifier: "PoemListCell", cellType: PoemListTableViewCell.self)) { row, poem, cell in
                
                cell.poemImageView.kf.setImage(with: poem.photoURL)
                cell.titleLabel.text = poem.title
                cell.likesLabel.text = "\(poem.likers.count)"
                cell.userLabel.text = poem.userPenname
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(Poem.self)
            .subscribe(onNext:{[weak self] poem in

                guard let self = self else {return}
                
                let viewModel = SemiDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                
                var semiDetailVC = SemiDetailViewController.instantiate(storyboardID: "WritingRelated")
                semiDetailVC.bind(viewModel: viewModel)
                
                semiDetailVC.modalTransitionStyle = .crossDissolve
                semiDetailVC.modalPresentationStyle = .overCurrentContext
                
                self.present(semiDetailVC, animated: true, completion: nil)

            })
            .disposed(by: rx.disposeBag)
    }
}

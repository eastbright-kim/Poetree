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
                cell.userLabel.text = poem.userNickname
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(Poem.self)
            .subscribe(onNext:{[unowned self] poem in

                let viewModel = PoemDetailViewModel(poemService: self.viewModel.poemService)
                var vc = PoemDetailViewController.instantiate(storyboardID: "WritingRelated")
                vc.currentPoem = poem
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
}

//
//  WritingDetailViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class PoemDetailViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    var viewModel: PoemDetailViewModel!
    var currentPoem: Poem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func bindViewModel() {
        
        self.userLabel.text = viewModel.output.user_date
        
        viewModel.output.aPoem
            .drive(onNext:{[unowned self] poem in
                print(poem.title)
                self.currentPoem = poem
                self.photoImageView.kf.setImage(with: poem.photoURL)
                self.contentLabel.text = poem.content
                self.titleLabel.text = poem.title
                self.likesCountLabel.text = "\(poem.likers.count)"
                let image = poem.isLike ? UIImage(systemName: "heart.fill")! : UIImage(systemName: "heart")!
                self.likeBtn.setImage(image, for: .normal)
            })
            .disposed(by: rx.disposeBag)
        
        
        self.editBtn.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                let viewModel = WriteViewModel(weekPhoto: nil, poemService: viewModel.poemService, editingPoem: self.currentPoem)
                var vc = WritingViewController.instantiate(storyboardID: "Main")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
}

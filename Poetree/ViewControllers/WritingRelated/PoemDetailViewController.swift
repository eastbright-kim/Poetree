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
import Firebase
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
    
    var currentPoem: Poem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpUI()
    }
    
    func setUpUI(){
        
        photoImageView.layer.cornerRadius = 8
        photoImageView.kf.setImage(with: currentPoem.photoURL)
        titleLabel.text = currentPoem.title
        userLabel.text = "\(currentPoem.userPenname)님이 \(convertDateToString(format: "MMM d", date: currentPoem.uploadAt))에 보낸 글"
        contentLabel.text = currentPoem.content
        likeBtn.isSelected = currentPoem.isLike
        likesCountLabel.text = "\(currentPoem.likers.count)"
        
        let currentUser = Auth.auth().currentUser
        if currentUser!.email != currentPoem.userEmail {
            self.editBtn.isHidden = true
            self.deleteBtn.isHidden = true
        }
    }
    
    
    func bindViewModel() {
        
        self.editBtn.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                let viewModel = WriteViewModel(poemService: viewModel.poemService, userService: viewModel.userService, weekPhoto: nil, editingPoem: self.currentPoem)
                var vc = WritingViewController.instantiate(storyboardID: "WritingRelated")
                vc.bind(viewModel: viewModel)
                vc.editingPoem = self.currentPoem
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.deleteBtn.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                self.viewModel.deletePoem(deletingPoem: currentPoem)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
}

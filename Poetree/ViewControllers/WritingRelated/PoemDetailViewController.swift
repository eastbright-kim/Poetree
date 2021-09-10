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
    @IBOutlet weak var backBtnItem: UIBarButtonItem!
    
    
    
    var viewModel: PoemDetailViewModel!
    
    var currentPoem: Poem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        setUpUI()
//    }
    
    func setUpUI(){
        
        photoImageView.layer.cornerRadius = 8
        photoImageView.kf.setImage(with: viewModel.output.displayingPoem.photoURL)
        titleLabel.text = viewModel.output.displayingPoem.title
        userLabel.text = "\(viewModel.output.displayingPoem.userPenname)님이 \(convertDateToString(format: "MMM d", date: viewModel.output.displayingPoem.uploadAt))에 보낸 글"
        contentLabel.text = viewModel.output.displayingPoem.content
        likeBtn.isSelected = viewModel.output.displayingPoem.isLike
        likesCountLabel.text = "\(viewModel.output.displayingPoem.likers.count)"
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
        
        if let currentUser = Auth.auth().currentUser, currentUser.uid == viewModel.output.displayingPoem.userUID {
            
            self.editBtn.isHidden = false
            self.deleteBtn.isHidden = false
            
        }
        
    }
    
    
    func bindViewModel() {
        
        self.backBtnItem.rx.tap
            .subscribe(onNext:{ _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        
        self.editBtn.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                
                let viewModel = WriteViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, writingType: .edit(self.viewModel.output.displayingPoem), editingPoem: self.viewModel.output.displayingPoem)
 
                var vc = WritingViewController.instantiate(storyboardID: "WritingRelated")
                vc.bind(viewModel: viewModel)
                vc.editingPoem = self.currentPoem
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.deleteBtn.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                self.viewModel.deletePoem(deletingPoem: self.viewModel.output.displayingPoem)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        
        
    }
    
}

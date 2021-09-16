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
import Toast_Swift

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
    @IBOutlet weak var reportBtn: UIBarButtonItem!
    
    var viewModel: PoemDetailViewModel!
    var isLike: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI(){
        likeBtn.startAnimatingPressActions()
//        likeBtn.setBackgroundColor(UIColor.label, for: .normal)
//        likeBtn.setBackgroundColor(UIColor.systemPink, for: .selected)
        photoImageView.layer.cornerRadius = 8
        photoImageView.kf.setImage(with: viewModel.output.displayingPoem.photoURL)
        titleLabel.text = viewModel.output.displayingPoem.title
        userLabel.text = "\(viewModel.output.displayingPoem.userPenname)님이 \(convertDateToString(format: "MMM d", date: viewModel.output.displayingPoem.uploadAt))에 보낸 글"
        contentLabel.text = viewModel.output.displayingPoem.content
        likeBtn.isSelected = viewModel.output.displayingPoem.isLike
        self.isLike = viewModel.output.displayingPoem.isLike
        likesCountLabel.text = "좋아요 \(viewModel.output.displayingPoem.likers.count)개"
        
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
                
                let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                backBarButtonItem.tintColor = .systemOrange
                self.navigationItem.backBarButtonItem = backBarButtonItem
                
                var vc = WritingViewController.instantiate(storyboardID: "WritingRelated")
                vc.bind(viewModel: viewModel)
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.deleteBtn.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                self.viewModel.deletePoem(deletingPoem: self.viewModel.output.displayingPoem)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.reportBtn.rx.tap
            .map{self.viewModel.output.displayingPoem}
            .subscribe(onNext:{ poem in
                let alert = UIAlertController(title: "글 신고하기", message: "비속어 등 악의적인 표현이 있는 글을 신고해주시기 바랍니다", preferredStyle: .actionSheet)
                let reportAction = UIAlertAction(title: "신고하기", style: .destructive) { _ in
                    let currentUser = Auth.auth().currentUser
                    self.viewModel.poemService.poemRepository.reportPoem(poem: poem, currentUser: currentUser) {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                alert.addAction(reportAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        likeBtn.rx.tap
            .map{_ in self.viewModel.output.displayingPoem}
            .subscribe(onNext:{ poem in
                if let currentUser = Auth.auth().currentUser {
                    self.viewModel.poemService.likeHandle(poem: poem, user: currentUser)
                    DispatchQueue.main.async {
                        self.likeBtn.isSelected = !self.likeBtn.isSelected
                    }
                } else {
                    DispatchQueue.main.async {
                        self.view.makeToast("좋아요를 위해서는 로그인이 필요합니다", duration: 0.7, position: .center)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        
        
        
    }
    
}

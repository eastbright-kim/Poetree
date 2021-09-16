//
//  SemiDetailViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/08.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Firebase
import Kingfisher
import Toast_Swift

class SemiDetailViewController: UIViewController, StoryboardBased, ViewModelBindable, HasDisposeBag {
    
    
    @IBOutlet weak var windowView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var contenTextView: UITextView!
    @IBOutlet weak var BGExitBtn: UIButton!
    @IBOutlet weak var detailBtn1: UIButton!
    @IBOutlet weak var detailBtn2: UIButton!
    
    var viewModel: SemiDetailViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI(){
        photoImageView.layer.cornerRadius = 8
        windowView.layer.cornerRadius = 8
    }
    
    
    func bindViewModel() {
        
        heartBtn.rx.tap
            .withLatestFrom(self.viewModel.output.displayingPoem)
            .subscribe(onNext:{ poem in
                if let currentUser = Auth.auth().currentUser {
                    self.viewModel.poemService.likeHandle(poem: poem, user: currentUser) { poem in
                        DispatchQueue.main.async {
                            self.heartBtn.isSelected = poem.isLike
                        }
                    }
                } else {
                    self.view.makeToast("좋아요를 위해서는 로그인이 필요합니다", duration: 0.7, position: .center)
                }
            })
            .disposed(by: rx.disposeBag)
       
        self.viewModel.output.displayingPoem
            .drive(onNext:{ poem in
                
                self.photoImageView.kf.setImage(with: poem.photoURL)
                self.authorLabel.text = poem.userPenname
                self.titleLabel.text = poem.title
                self.contenTextView.text = poem.content
                self.heartBtn.isSelected = poem.isLike
                
            })
            .disposed(by: rx.disposeBag)
        
        
        exitBtn.rx.tap
            .subscribe(onNext:{ _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        BGExitBtn.rx.tap
            .subscribe(onNext:{ _ in
                
                self.dismiss(animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
        detailBtn1.rx.tap
            .withLatestFrom(self.viewModel.output.displayingPoem)
            .subscribe(onNext:{ poem in
                
                print(poem.isLike)
                
                let viewModel = PoemDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                var detailVC = PoemDetailViewController.instantiate(storyboardID: "WritingRelated")
                detailVC.bind(viewModel: viewModel)
                detailVC.modalPresentationStyle = .overFullScreen
                detailVC.modalTransitionStyle = .crossDissolve
                
                let navi = UINavigationController(rootViewController: detailVC)
                
                self.present(navi, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        detailBtn2.rx.tap
            .withLatestFrom(self.viewModel.output.displayingPoem)
            .subscribe(onNext:{ poem in
                let viewModel = PoemDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                var detailVC = PoemDetailViewController.instantiate(storyboardID: "WritingRelated")
                detailVC.bind(viewModel: viewModel)
                detailVC.modalPresentationStyle = .overFullScreen
                detailVC.modalTransitionStyle = .crossDissolve
                let navi = UINavigationController(rootViewController: detailVC)
                self.present(navi, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
    }
}

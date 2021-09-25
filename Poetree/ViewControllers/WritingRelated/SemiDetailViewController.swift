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
    @IBOutlet weak var privateBtn: UIButton!
    
    
    
    var viewModel: SemiDetailViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI(){
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        self.contenTextView.attributedText = NSAttributedString(string: self.contenTextView.text, attributes: attributes)
        self.contenTextView.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        photoImageView.layer.cornerRadius = 8
        windowView.layer.cornerRadius = 8
        self.privateBtn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        self.privateBtn.layer.cornerRadius = 5
    }
    
    
    func bindViewModel() {
        
        heartBtn.rx.tap
            .do(onNext: { [weak self] _ in guard let self = self else {return}
                self.heartBtn.animateView()
            })
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
                if Auth.auth().currentUser == nil {
                    self.heartBtn.isSelected = false
                }
                
                if self.viewModel.output.isTempSemiDetail {
                    self.heartBtn.isHidden = true
                }
                self.privateBtn.isHidden = !poem.isPrivate
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
                
                if let currentUser = Auth.auth().currentUser {
                    
                    let viewModel =  self.viewModel.output.isTempSemiDetail ? PoemDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService, isTempDetail: true) : PoemDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService, isUserWriting: (currentUser.uid == poem.userUID))
                    
                    var detailVC = PoemDetailViewController.instantiate(storyboardID: "WritingRelated")
                    detailVC.bind(viewModel: viewModel)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                    let navi = UINavigationController(rootViewController: detailVC)
                    navi.modalTransitionStyle = .crossDissolve
                    navi.modalPresentationStyle = .overFullScreen
                    self.present(navi, animated: true, completion: nil)
                    
                    
                } else {

                    let viewModel = PoemDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                    
                    var detailVC = PoemDetailViewController.instantiate(storyboardID: "WritingRelated")
                    detailVC.bind(viewModel: viewModel)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                    let navi = UINavigationController(rootViewController: detailVC)
                    navi.modalTransitionStyle = .crossDissolve
                    navi.modalPresentationStyle = .overFullScreen
                    self.present(navi, animated: true, completion: nil)
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        detailBtn2.rx.tap
            .withLatestFrom(self.viewModel.output.displayingPoem)
            .subscribe(onNext:{ poem in
                let viewModel = PoemDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                var detailVC = PoemDetailViewController.instantiate(storyboardID: "WritingRelated")
                detailVC.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(detailVC, animated: true)
                let navi = UINavigationController(rootViewController: detailVC)
                navi.modalTransitionStyle = .crossDissolve
                navi.modalPresentationStyle = .overFullScreen
                self.present(navi, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }
}

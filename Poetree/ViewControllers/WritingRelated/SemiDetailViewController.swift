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

class SemiDetailViewController: UIViewController, StoryboardBased, ViewModelBindable, HasDisposeBag {
    
    
    @IBOutlet weak var windowView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var contenTextView: UITextView!
    
    
    var viewModel: SemiDetailViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI(){
        
        windowView.layer.cornerRadius = 8
        heartBtn.isSelected = self.viewModel.poem.isLike
        
    }
    
    
    func bindViewModel() {
        
        heartBtn.rx.tap
            .subscribe(onNext:{ _ in
                if let currentUser = Auth.auth().currentUser {
                    self.viewModel.poemService.likeHandle(poem: self.viewModel.poem, user: currentUser)
                    DispatchQueue.main.async {
                        self.heartBtn.isSelected = !self.heartBtn.isSelected
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        self.photoImageView.kf.setImage(with: self.viewModel.poem.photoURL)
        
        self.authorLabel.text = self.viewModel.poem.userPenname
        
        self.titleLabel.text = self.viewModel.poem.title
        
        self.contenTextView.text = self.viewModel.poem.content
        
    }
}

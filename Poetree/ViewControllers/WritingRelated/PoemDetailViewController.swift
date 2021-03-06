//
//  WritingDetailViewController.swift
//  Poetree
//
//  Created by κΉλν on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Firebase
import Toast_Swift

class PoemDetailViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var backBtnItem: UIBarButtonItem!
    @IBOutlet weak var reportBtn: UIBarButtonItem!
    @IBOutlet weak var keepWriteBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    
    var viewModel: PoemDetailViewModel!
    var isLike: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemOrange]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = UIColor.systemOrange
    }
    
    func configNavBar() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = UIColor.label
    }
    
    func configureUI(){
        
        makePhotoViewShadow(superView: photoView, photoImageView: photoImageView)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        self.contentLabel.attributedText = NSAttributedString(string: self.contentLabel.text, attributes: attributes)
        self.contentLabel.font = UIFont.systemFont(ofSize: 18, weight: .light)
        
        self.photoImageView.layer.cornerRadius = 8
        self.privateBtn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        self.privateBtn.layer.cornerRadius = 5
        
    }
    
    
    func bindViewModel() {
  
        self.viewModel.displayingPoem
            .drive(onNext:{ [weak self] poem in
                
                guard let self = self else {return}
                
                self.photoImageView.kf.setImage(with: poem.photoURL)
                self.titleLabel.text = poem.title
                self.contentLabel.text = poem.content
                self.userLabel.text = "\(poem.userPenname)λμ΄ \(convertDateToString(format: "MMM d", date: poem.uploadAt))μ λ³΄λΈ κΈ"
                self.isLike = poem.isLike
                self.likesCountLabel.text = "μ’μμ \(poem.likers.count)κ°"
                self.likeBtn.isSelected = poem.isLike
                self.privateBtn.isHidden = !poem.isPrivate
                
                if Auth.auth().currentUser == nil {
                    self.likeBtn.isSelected = false
                }
                
                if self.viewModel.isTempDetail {
                    self.likeBtn.isHidden = true
                    self.likesCountLabel.isHidden = true
                    self.deleteBtn.isHidden = false
                    self.editBtn.isHidden = true
                    self.keepWriteBtn.isHidden = false
                } else if self.viewModel.isUserWriting {
                    self.deleteBtn.isHidden = false
                    self.editBtn.isHidden = false
                    self.keepWriteBtn.isHidden = true
                }
                
            })
            .disposed(by: rx.disposeBag)
        
        
        self.backBtnItem.rx.tap
            .subscribe(onNext:{ _ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        self.editBtn.rx.tap
            .withLatestFrom(self.viewModel.displayingPoem)
            .subscribe(onNext:{[weak self] poem in
                
                guard let self = self else {return}
                
                let viewModel = WriteViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, writingType: .edit(poem), beforeEditedPoem: poem)
                
                let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                backBarButtonItem.tintColor = .systemOrange
                self.navigationItem.backBarButtonItem = backBarButtonItem
                
                var vc = WritingViewController.instantiate(storyboardID: "WritingRelated")
                vc.bind(viewModel: viewModel)
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.keepWriteBtn.rx.tap
            .withLatestFrom(self.viewModel.displayingPoem)
            .subscribe(onNext:{[weak self] poem in
                
                guard let self = self else {return}
                
                let viewModel = WriteViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, writingType: .temp(poem))
                
                let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                backBarButtonItem.tintColor = .systemOrange
                self.navigationItem.backBarButtonItem = backBarButtonItem
                
                var vc = WritingViewController.instantiate(storyboardID: "WritingRelated")
                vc.bind(viewModel: viewModel)
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.deleteBtn.rx.tap
            .withLatestFrom(self.viewModel.displayingPoem)
            .subscribe(onNext:{[weak self] poem in
                
                guard let self = self else {return}
                let deleteAlert = self.fetchAlertForDelete(poem: poem)
                self.present(deleteAlert, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
        self.reportBtn.rx.tap
            .withLatestFrom(self.viewModel.displayingPoem)
            .subscribe(onNext:{ poem in
                
                guard self.viewModel.isTempDetail == false else { self.view.makeToast("μμλ‘ μ μ₯λ κΈμ μ κ³ ν  μ μμ΅λλ€", duration: 1.0, position: .center)
                    return}
                let reportAlert = self.fetchAlertForReport(poem: poem)
                self.present(reportAlert, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        
        likeBtn.rx.tap
            .do(onNext:{ [weak self] _ in guard let self = self else {return}
                    self.likeBtn.animateView()})
            .withLatestFrom(self.viewModel.displayingPoem)
            .subscribe(onNext:{ poem in
                if let currentUser = Auth.auth().currentUser {
                    self.viewModel.poemService.likeHandle(poem: poem, user: currentUser){ poem in
                        DispatchQueue.main.async {
                            self.likeBtn.isSelected = poem.isLike
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.view.makeToast("μ’μμλ₯Ό μν΄μλ λ‘κ·ΈμΈμ΄ νμν©λλ€", duration: 0.7, position: .center)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
}

//MARK: - Fetch UIAlert

extension PoemDetailViewController {
    
    func fetchAlertForDelete(poem: Poem) -> UIAlertController {
        let alert = UIAlertController(title: "κΈ μ­μ ", message: "κΈμ μ­μ νμκ² μ΅λκΉ?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "νμΈ", style: .destructive) { action in
            self.viewModel.poemService.deletePoem(deletingPoem: poem)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindfromDetailView", sender: self)
            }
        }
        let cancelAction = UIAlertAction(title: "μ·¨μ", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        return alert
    }
    
    func fetchAlertForReport(poem: Poem) -> UIAlertController {
        let alert = UIAlertController(title: "μ κ³ νκΈ°", message: "λΉμμ΄ λ± μμμ μΈ ννμ΄ μλ κΈμ μ κ³ ν΄ μ£ΌμκΈ° λ°λλλ€.\nμ κ³ λ κΈμ μΆνμ λ³Ό μ μμΌλ©°\nμ μ μ± κ²ν  νμ κΈμ΄μ΄μ Poetree μ΄μ©μ μ νν©λλ€.\nλν, κΈμ΄μ΄λ₯Ό μ°¨λ¨ν  κ²½μ°, μ΄ν ν΄λΉ κΈμ΄μ΄μ κΈμ λ³Ό μ μμ΅λλ€.\nμ°Έμ¬ν΄μ£Όμμ κ°μ¬ν©λλ€.", preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "μ κ³ νκΈ°", style: .destructive) { _ in
            let currentUser = Auth.auth().currentUser
            
            self.viewModel.poemService.reportPoem(poem: poem, currentUser: currentUser) {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwindfromDetailView", sender: self)
                }
            }
        }
        let blockAction = UIAlertAction(title: "κΈμ΄μ΄ μ°¨λ¨νκΈ°", style: .destructive) { _ in
            guard let currentUser = Auth.auth().currentUser else {
                
                let alert = UIAlertController(title: "λ‘κ·ΈμΈμ΄ νμν©λλ€", message: "κΈμ΄μ΄ μ°¨λ¨ κΈ°λ₯μ\nλ‘κ·ΈμΈ ν μ΄μ©ν  μ μμ΅λλ€", preferredStyle: .alert)
                let action = UIAlertAction(title: "νμΈ", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return}
            
            self.viewModel.poemService.blockWriter(poem: poem, currentUser: currentUser) {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwindfromDetailView", sender: self)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "μ·¨μ", style: .cancel, handler: nil)
        alert.addAction(reportAction)
        alert.addAction(blockAction)
        alert.addAction(cancelAction)
        return alert
    }
}

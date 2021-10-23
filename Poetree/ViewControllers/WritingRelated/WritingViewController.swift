//
//  WritingViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Kingfisher
import Toast_Swift
import BLTNBoard

class WritingViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {
    
    var viewModel: WriteViewModel!
    
    @IBOutlet weak var selectedPhoto: UIImageView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var userDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var privateCheckBtn: UIButton!
    @IBOutlet weak var editCompleteBtn: UIButton!
    @IBOutlet weak var writeCompleteBtn: UIButton!
    @IBOutlet weak var backScrollView: UIScrollView!
    @IBOutlet weak var publicNoticeLabel: UILabel!
    @IBOutlet weak var privateNoticeLabel: UILabel!
    @IBOutlet weak var saveTempPoem: UIBarButtonItem!
    
    private lazy var addTempPoemFromWriting: BLTNItemManager = {
        let item = BLTNPageItem(title: "이 글을 임시 저장하시겠습니까?")
        item.descriptionText = "임시 저장한 후에는 My Poem탭의\n임시 저장한 글에서 확인하실 수 있습니다"
        item.actionButtonTitle = "저장"
        item.alternativeButtonTitle = "아니요"
        item.appearance.titleFontSize = 20
        item.appearance.titleTextColor = UIColor.black
        item.appearance.descriptionFontSize = 15
        item.appearance.descriptionTextColor = UIColor.darkGray
        item.actionHandler = { _ in
            self.addTempFromWriting()
        }
        item.alternativeHandler = { _ in
            self.cancelSave()
        }
        return BLTNItemManager(rootItem: item)
    }()
    
    private lazy var editTempPoemManager: BLTNItemManager = {
        let item = BLTNPageItem(title: "이 글을 임시 저장하시겠습니까?")
        item.appearance.titleFontSize = 20
        item.appearance.titleTextColor = UIColor.black
        item.descriptionText = "임시 저장하는 글은 비공개로 저장됩니다"
        item.appearance.descriptionFontSize = 15
        item.appearance.descriptionTextColor = UIColor.darkGray
        item.actionButtonTitle = "저장"
        item.alternativeButtonTitle = "삭제"
        item.actionHandler = { _ in
            self.saveTempFromTemp()
        }
        item.alternativeHandler = { _ in
            self.deletePoem()
        }
        return BLTNItemManager(rootItem: item)
    }()
    
    var keyboardDismissTabGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
    var isPrvate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addObserver()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    func addObserver(){
        self.keyboardDismissTabGesture.delegate = self
        self.view.addGestureRecognizer(keyboardDismissTabGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard() {
        self.backScrollView.contentInset.bottom = 0
        self.view.endEditing(true)
    }
    
    func setUpNavUI() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.systemOrange]
        self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
        self.navigationController?.navigationBar.tintColor = UIColor.systemOrange
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let type = self.viewModel.writingType
        switch type {
        case .write:
            self.title = "글 쓰기"
        case .edit:
            self.title = "글 수정하기"
        case .temp:
            self.title = "글 이어서 쓰기"
        }
    }
    
    func setUpUI(){
        
        makePhotoViewShadow(superView: photoView, photoImageView: selectedPhoto)
        selectedPhoto.layer.cornerRadius = 8
        self.writeCompleteBtn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        self.writeCompleteBtn.layer.cornerRadius = 5
        self.editCompleteBtn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        self.editCompleteBtn.layer.cornerRadius = 5
        
        let type = self.viewModel.writingType
        switch type {
        case .edit(let editingPoem):
            self.selectedPhoto.kf.setImage(with: editingPoem.photoURL)
            self.userDateLabel.text = viewModel.poemService.getWritingTimeString(date: editingPoem.uploadAt)
            self.titleTextField.text = editingPoem.title
            self.contentTextView.text = editingPoem.content
            self.privateCheckBtn.isSelected = editingPoem.isPrivate
            self.isPrvate = editingPoem.isPrivate
            if editingPoem.isPrivate {
                self.privateNoticeLabel.isHidden = false
                self.publicNoticeLabel.isHidden = true
            } else {
                self.privateNoticeLabel.isHidden = true
                self.publicNoticeLabel.isHidden = false
            }
            self.writeCompleteBtn.isHidden = true
        case .write(let weekPhoto):
            self.selectedPhoto.kf.setImage(with: weekPhoto.url)
            self.userDateLabel.text = viewModel.poemService.getWritingTimeString(date: Date())
            self.editCompleteBtn.isHidden = true
            self.publicNoticeLabel.isHidden = false
        case .temp(let writingPoem):
            self.selectedPhoto.kf.setImage(with: writingPoem.photoURL)
            self.userDateLabel.text = viewModel.poemService.getWritingTimeString(date: Date())
            self.titleTextField.text = writingPoem.title
            self.contentTextView.text = writingPoem.content
            self.privateCheckBtn.isSelected = writingPoem.isPrivate
            self.isPrvate = writingPoem.isPrivate
            if writingPoem.isPrivate {
                self.privateNoticeLabel.isHidden = false
                self.publicNoticeLabel.isHidden = true
            } else {
                self.privateNoticeLabel.isHidden = true
                self.publicNoticeLabel.isHidden = false
            }
            self.editCompleteBtn.isHidden = true
        }
    }
    
    func bindViewModel() {
        
        self.titleTextField.rx.text.orEmpty
            .bind(onNext: { title in
                self.viewModel.input.title.onNext(title)
            })
            .disposed(by: rx.disposeBag)
        
        self.contentTextView.rx.text.orEmpty
            .bind(onNext: { content in
                self.viewModel.input.content.onNext(content)
            })
            .disposed(by: rx.disposeBag)
        
        privateCheckBtn.rx.tap
            .do(onNext:{self.isPrvate = !self.isPrvate
                self.privateCheckBtn.isSelected.toggle()
                if self.isPrvate == false {
                    self.publicNoticeLabel.isHidden = false
                    self.privateNoticeLabel.isHidden = true
                }else {
                    self.publicNoticeLabel.isHidden = true
                    self.privateNoticeLabel.isHidden = false
                }
            })
            .map{self.isPrvate}
            .bind(to: viewModel.input.isPrivate)
            .disposed(by: rx.disposeBag)
        
        writeCompleteBtn.rx.tap
            .withLatestFrom(self.viewModel.output.aPoem)
            .subscribe(onNext:{ poem in
                
                if let alertController = self.viewModel.fetchAlertForInvalidPoem(poem: poem) {
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                DispatchQueue.global().async {
                    self.viewModel.poemService.createPoem(poem: poem) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                let writingType = self.viewModel.writingType
                                if self.viewModel.isFromMain {
                                    self.navigationController?.popToRootViewController(animated: true)
                                } else if case .temp = writingType {
                                    self.performSegue(withIdentifier: "unwindfromWritingView", sender: self)
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        editCompleteBtn.rx.tap
            .withLatestFrom(self.viewModel.output.aPoem)
            .subscribe(onNext:{ poem in
                
                guard let poemBeforeEdited = self.viewModel.beforeEditedPoem else {return}
                
                if let alertController = self.viewModel.fetchAlertForInvalidPoem(poem: poem) {
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                DispatchQueue.global().async {
                    self.viewModel.poemService.editPoem(beforeEdited: poemBeforeEdited, editedPoem: poem) { result in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                }
            })
            .disposed(by: rx.disposeBag)
        
        saveTempPoem.rx.tap
            .withLatestFrom(self.viewModel.output.aPoem)
            .subscribe(onNext:{ [weak self] poem in
                
                guard let weakSelf = self else {return}
                
                if let alertForBadword = weakSelf.viewModel.fetchBadwordAlert(poem: poem) {
                    weakSelf.present(alertForBadword, animated: true, completion: nil)
                    return
                }
                
                let type = weakSelf.viewModel.writingType
                switch type {
                case .write:
                    weakSelf.addTempPoemFromWriting.showBulletin(above: weakSelf)
                case .temp:
                    weakSelf.editTempPoemManager.showBulletin(above: weakSelf)
                case .edit:
                    weakSelf.editTempPoemManager.showBulletin(above: weakSelf)
                }
                
            })
            .disposed(by: rx.disposeBag)
    }
    
}

extension WritingViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if(touch.view?.isDescendant(of: self.titleTextField) == true){
            return false
        } else if (touch.view?.isDescendant(of: self.contentTextView) == true){
            return false
        } else {
            view.endEditing(true)
            return true
        }
    }
}

//MARK: - BLTN Board related
extension WritingViewController {
    
    func addTempFromWriting(){
        self.addTempPoemFromWriting.dismissBulletin()
        viewModel.output.aPoem
            .take(1)
            .observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .subscribe(onNext:{ savingPoem in
                self.viewModel.poemService.createTempPoem(poem: savingPoem) { result in
                    print(result)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func cancelSave() {
        self.addTempPoemFromWriting.dismissBulletin(animated: false)
    }
    
    func saveTempFromTemp(){
        
        self.editTempPoemManager.dismissBulletin(animated: true)
        self.title = "글 이어서 쓰기"
        viewModel.output.aPoem
            .take(1)
            .observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .subscribe(onNext:{ savingPoem in
                self.viewModel.poemService.editTempPoem(poem: savingPoem) { result in
                    DispatchQueue.main.async {
                        self.view.makeToast("임시 저장 완료", duration: 1, position: .center)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func deletePoem(){
        self.editTempPoemManager.dismissBulletin(animated: true)
        
        let alert = UIAlertController(title: "삭제", message: "이 글을 삭제하시겠습니까?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] action in
            
            guard let self = self else {return}
            
            self.viewModel.output.aPoem
                .take(1)
                .observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
                .subscribe(onNext:{ deletingPoem in
                    self.viewModel.poemService.deletePoem(deletingPoem: deletingPoem)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "unwindfromWritingView", sender: self)
                    }
                    
                })
                .disposed(by: self.rx.disposeBag)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

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
import RxKeyboard
import BLTNBoard

class WritingViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {
    
    var viewModel: WriteViewModel!
    
    @IBOutlet weak var selectedPhoto: UIImageView!
    @IBOutlet weak var userDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var privateChechBtn: UIButton!
    @IBOutlet weak var editComplete: UIButton!
    @IBOutlet weak var writeComplete: UIButton!
    @IBOutlet weak var backScrollView: UIScrollView!
    
    private lazy var writingTempManager: BLTNItemManager = {
        let item = BLTNPageItem(title: "임시 저장")
        item.descriptionText = "이 글을 임시 저장 하시겠습니까?\n\n임시 저장 후에는 My Poem탭의\n보관한 글에서 확인하실 수 있습니다."
        item.actionButtonTitle = "저장"
        item.alternativeButtonTitle = "아니요"
        item.actionHandler = { _ in
            self.addTempFromWriting()
        }
        item.alternativeHandler = { _ in
            self.cancelSave()
        }
        
        return BLTNItemManager(rootItem: item)
    }()
    
    private lazy var tempManager: BLTNItemManager = {
        let item = BLTNPageItem(title: "임시 저장")
        item.descriptionText = "이 글을 임시 저장 하시겠습니까?"
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
    
    var editingPoem: Poem?
    var isPrvate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func dismissKeyboard() {
        self.backScrollView.contentInset.bottom = 0
        self.view.endEditing(true)
    }
    
    func setUpUI(){
        
        selectedPhoto.layer.cornerRadius = 8
        self.keyboardDismissTabGesture.delegate = self
        self.view.addGestureRecognizer(keyboardDismissTabGesture)
        let type = self.viewModel.output.writingType
        
        switch type {
        
        case .edit(let editingPoem):
            self.selectedPhoto.kf.setImage(with: editingPoem.photoURL)
            self.userDateLabel.text = viewModel.poemService.getWritingTimeString(date: editingPoem.uploadAt)
            self.titleTextField.text = editingPoem.title
            self.contentTextView.text = editingPoem.content
            self.privateChechBtn.isSelected = editingPoem.isPrivate
            self.writeComplete.isHidden = true
            
        case .write(let weekPhoto):
            self.selectedPhoto.kf.setImage(with: weekPhoto.url)
            self.userDateLabel.text = viewModel.poemService.getWritingTimeString(date: Date())
            self.editComplete.isHidden = true
            
        case .temp(let writingPoem):
            
            self.selectedPhoto.kf.setImage(with: writingPoem.photoURL)
            self.userDateLabel.text = viewModel.poemService.getWritingTimeString(date: writingPoem.uploadAt)
            self.titleTextField.text = writingPoem.title
            self.contentTextView.text = writingPoem.content
            self.privateChechBtn.isSelected = writingPoem.isPrivate
            self.writeComplete.isHidden = false
            
        }
        
        titleTextField.addDoneButtonOnKeyboard()
        contentTextView.addDoneButtonOnKeyboard()
        
    }
    
    func bindViewModel() {
        
        Observable.combineLatest(self.titleTextField.rx.text.orEmpty, RxKeyboard.instance.willShowVisibleHeight.asObservable())
            .bind { [weak self] title, height in
                
                guard let self = self else {return}
                self.viewModel.input.title.onNext(title)
                self.backScrollView.contentInset.bottom = height
                self.backScrollView.contentOffset.y = height / 2
            }
            .disposed(by: rx.disposeBag)
        
        contentTextView.rx.text.orEmpty
            .bind(to: viewModel.input.content)
            .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(self.contentTextView.rx.text.orEmpty, RxKeyboard.instance.visibleHeight.asObservable())
            .bind { [weak self] content, height in
                
                guard let self = self else {return}
                
                self.viewModel.input.content.onNext(content)
                self.backScrollView.contentOffset.y = height
                self.contentTextView.contentInset.bottom = height
            }
            .disposed(by: rx.disposeBag)
        
        privateChechBtn.rx.tap
            .do(onNext:{self.isPrvate = !self.isPrvate
                self.privateChechBtn.isSelected.toggle()
            })
            .map{[unowned self] in self.isPrvate}
            .bind(to: viewModel.input.isPrivate)
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func sendPoemTapped(_ sender: UIButton) {
        
        if checkBadWords(content: self.contentTextView.text + self.titleTextField.text!){
            
            let alert = UIAlertController(title: "이상 내용 감지", message: "창작의 자유를 존중하지만\n정책상 비속어 게시가 불가합니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if self.titleTextField.text!.isEmpty && self.contentTextView.text.isEmpty {
            
            let alert = UIAlertController(title: "이상 내용 감지", message: "공백의 글은 게시할 수 없습니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if self.isPrvate == false {
            
            let alert = UIAlertController(title: "공개하는 글", message: "Poetree가 모두에게 소중한 공간이 될 수 있도록 협조해주세요 :)", preferredStyle: .alert)
            
            let writeAction = UIAlertAction(title: "확인", style: .default) { action in
                
                self.viewModel.output.aPoem
                    .take(1)
                    .observe(on: ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global()))
                    .subscribe(onNext: {[weak self] aPoem in
                        
                        guard let self = self else {return}
                        
                        self.viewModel.poemService.createPoem(poem: aPoem) { result in
                            print(result)
                        }
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                    .disposed(by: self.rx.disposeBag)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { action in
                return
            }
            
            alert.addAction(writeAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "글 쓰기", message: "글을 공개하지 않고 보관합니다", preferredStyle: .alert)
            let writeAction = UIAlertAction(title: "확인", style: .default) { action in
                self.viewModel.output.aPoem
                    .take(1)
                    .observe(on: ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global()))
                    .subscribe(onNext: {[weak self] aPoem in
                        
                        guard let self = self else {return}
                        
                        self.viewModel.poemService.createPoem(poem: aPoem) { result in
                            print(result)
                        }
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: true)
                            
                        }
                    })
                    .disposed(by: self.rx.disposeBag)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { action in
                return
            }
            alert.addAction(writeAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func editCompleteTapped(_ sender: UIButton) {
        
        if checkBadWords(content: self.contentTextView.text + self.titleTextField.text!){
            
            let alert = UIAlertController(title: "이상 내용 감지", message: "창작의 자유를 존중하지만\n정책상 비속어 게시가 불가합니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if self.titleTextField.text!.isEmpty && self.contentTextView.text.isEmpty {
            
            let alert = UIAlertController(title: "이상 내용 감지", message: "공백의 글은 게시할 수 없습니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        if self.isPrvate == false {
            
            let alert = UIAlertController(title: "공개하는 글", message: "Poetree가 모두에게 소중한 공간이 될 수 있도록 협조해주세요 :)", preferredStyle: .alert)
            
            let writeAction = UIAlertAction(title: "확인", style: .default) { action in
                
                self.viewModel.output.aPoem
                    .take(1)
                    .observe(on: ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global()))
                    .subscribe(onNext: {[weak self] editedPoem in
                        
                        guard let self = self, let editingPoem = self.viewModel.output.editingPoem else {return}
                        
                        self.viewModel.poemService.editPoem(beforeEdited: editingPoem, editedPoem: editedPoem) { result in
                            print(result)
                            
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                                guard let detailVC = self.navigationController?.topViewController as? PoemDetailViewController else {return}
                                detailVC.currentPoem = editedPoem
                            }
                        }
                    })
                    .disposed(by: self.rx.disposeBag)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { action in
                return
            }
            
            alert.addAction(writeAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "글 쓰기", message: "글을 공개하지 않고 보관합니다", preferredStyle: .alert)
            let writeAction = UIAlertAction(title: "확인", style: .default) { action in
                self.viewModel.output.aPoem
                    .take(1)
                    .observe(on: ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global()))
                    .subscribe(onNext: {[weak self] editedPoem in
                        
                        guard let self = self, let editingPoem = self.viewModel.output.editingPoem else {return}
                        
                        self.viewModel.poemService.editPoem(beforeEdited: editingPoem, editedPoem: editedPoem) { result in
                            print(result)
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                                guard let detailVC = self.navigationController?.topViewController as? PoemDetailViewController else {return}
                                detailVC.currentPoem = editedPoem
                            }
                        }
                        
                    })
                    .disposed(by: self.rx.disposeBag)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { action in
                return
            }
            alert.addAction(writeAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func tempSaveBtnTapped(_ sender: UIBarButtonItem) {
        
        if checkBadWords(content: self.contentTextView.text + self.titleTextField.text!){
            
            let alert = UIAlertController(title: "이상 내용 감지", message: "창작의 자유를 존중하지만\n정책상 비속어 게시가 불가합니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let type = self.viewModel.output.writingType
        
        switch type {
        case .write:
            self.writingTempManager.showBulletin(above: self)
            
        case .edit:
            self.tempManager.showBulletin(above: self)
            
        default:
            break
        }
    }
    
    func addTempFromWriting(){
        
        self.writingTempManager.dismissBulletin()
        
        viewModel.output.aPoem
            .take(1)
            .observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .subscribe(onNext:{ savingPoem in
                self.viewModel.poemService.tempCreate(poem: savingPoem) { result in
                    print(result)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    func cancelSave() {
        self.writingTempManager.dismissBulletin(animated: false)
    }
    
    func saveTempFromTemp(){
        
        self.tempManager.dismissBulletin(animated: true)
        
        viewModel.output.aPoem
            .take(1)
            .observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .subscribe(onNext:{ savingPoem in
                self.viewModel.poemService.editTemp(poem: savingPoem) { result in
                    print(result)
                    DispatchQueue.main.async {
                        self.view.makeToast("임시 저장 완료", duration: 1, position: .center)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    func deletePoem(){
        self.tempManager.dismissBulletin(animated: true)
        
        let alert = UIAlertController(title: "삭제", message: "이 글을 삭제하시겠습니까?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] action in
            
            guard let self = self else {return}
            
            self.viewModel.output.aPoem
                .take(1)
                .observe(on: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
                .subscribe(onNext:{ deletingPoem in
                    self.viewModel.poemService.deletePoem(deletingPoem: deletingPoem)
                })
                .disposed(by: self.rx.disposeBag)
            
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
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

extension UITextField {
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = .link
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
        
    }
}

extension UITextView {
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = .link
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}

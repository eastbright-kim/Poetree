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
        
        if checkBadWords(content: self.contentTextView.text){
                   
                   let alert = UIAlertController(title: "이상 내용 감지", message: "창작의 자유를 존중하지만, 정책상 비속어 게시가 불가합니다", preferredStyle: .alert)
                   let action = UIAlertAction(title: "확인", style: .default)
                   
                   alert.addAction(action)
                   self.present(alert, animated: true, completion: nil)
                   
                   return
               }

        
        viewModel.output.aPoem
            .take(1)
            .observe(on: ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global()))
            .subscribe(onNext: {[unowned self] aPoem in
                self.viewModel.createPoem(poem: aPoem)
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func editCompleteTapped(_ sender: UIButton) {
        
        viewModel.output.aPoem
            .take(1)
            .subscribe(onNext:{ [weak self] poem in
                
                guard let self = self, let editingPoem = self.viewModel.output.editingPoem else {return}
                
                self.viewModel.editPoem(beforeEdited: editingPoem, editedPoem: poem)
                    
                    self.navigationController?.popViewController(animated: true)
                    guard let detailVC = self.navigationController?.topViewController as? PoemDetailViewController else {return}
                    detailVC.currentPoem = poem
                
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

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

class WritingViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {
    
    var viewModel: WriteViewModel!
    
    @IBOutlet weak var selectedPhoto: UIImageView!
    @IBOutlet weak var userDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var privateChechBtn: UIButton!
    @IBOutlet weak var editComplete: UIButton!
    @IBOutlet weak var writeComplete: UIButton!
    
    var editingPoem: Poem?
    
    var isPrvate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    func setUpUI(){
        
        selectedPhoto.layer.cornerRadius = 8
        
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
        
        
    }
    
    func bindViewModel() {
      
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.input.title)
            .disposed(by: rx.disposeBag)
        
        contentTextView.rx.text.orEmpty
            .bind(to: viewModel.input.content)
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

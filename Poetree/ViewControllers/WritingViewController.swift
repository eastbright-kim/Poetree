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

class WritingViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {
    
    var viewModel: WritePoemViewModel!
    
    @IBOutlet weak var selectedPhoto: UIImageView!
    @IBOutlet weak var userDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var privateChechBtn: UIButton!
    
    var isPublic = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    
    func bindViewModel() {
      
        selectedPhoto.kf.setImage(with: viewModel.output.photoDisplayed)
        
        viewModel.output.getCurrentDate
            .drive(userDateLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.input.title)
            .disposed(by: rx.disposeBag)
            
        contentTextView.rx.text.orEmpty
            .bind(to: viewModel.input.content)
            .disposed(by: rx.disposeBag)
        
        privateChechBtn.rx.tap
            .do(onNext:{self.isPublic = !self.isPublic})
            .map{[unowned self] in self.isPublic}
            .bind(to: viewModel.input.isPublic)
            .disposed(by: rx.disposeBag)
        
    }

    @IBAction func sendPoemTapped(_ sender: UIButton) {
        
        
        viewModel.output.aPoem
            .take(1)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(queue: DispatchQueue.global()))
            .subscribe(onNext: {[unowned self] aPoem in
                self.viewModel.createPeom(poem: aPoem)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: rx.disposeBag)
    }
}

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    
    func bindViewModel() {
      
        selectedPhoto.kf.setImage(with: viewModel.selectedPhoto.url)
        
        viewModel.output.getCurrentDate
            .drive(userDateLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
    }

}

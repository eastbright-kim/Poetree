//
//  WritingDetailViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class PoemDetailViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    
    
    var viewModel: PoemDetailViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    func bindViewModel() {
        
    }
}

//
//  UserPageViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseAuth

class UserPageViewController: UIViewController, ViewModelBindable, StoryboardBased {

    var viewModel: MyPoemViewModel!
    @IBOutlet weak var userRegister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(Auth.auth().currentUser?.uid)
        
    }
    
    private func configureUI() {
        
        configureNavTab()
        
    }
    
    private func configureNavTab() {
        self.navigationItem.title = "My Poem"
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.tabBarItem.image = UIImage(systemName: "person.fill")
        self.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
        self.tabBarItem.title = "My Poem"
    }
    
    func bindViewModel() {
        
        userRegister.rx.tap
            .subscribe(onNext:{[unowned self]
                _ in
                
                let viewModel = UserRegisterViewModel(userService: self.viewModel.userService)
                
                var vc = UserRegisterViewController.instantiate(storyboardID: "UserRelated")
                
                vc.bind(viewModel: viewModel)
                
                self.present(vc, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
    }


}

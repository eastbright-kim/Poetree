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
import SideMenu

class UserPageViewController: UIViewController, ViewModelBindable, StoryboardBased {

    @IBOutlet weak var navBarBtn: UIBarButtonItem!
    
    
    var viewModel: MyPoemViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        
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
        

        
        navBarBtn.rx.tap
            .subscribe(onNext:{ [unowned self] _ in
                
                let vm = UserRegisterViewModel(userService: self.viewModel.userService)
                let sb = UIStoryboard(name: "UserRelated", bundle: nil)
                var vc = sb.instantiateViewController(identifier: "UserRegisterViewController") as! UserRegisterViewController
                vc.bind(viewModel: vm)
                
                present(vc, animated: false, completion: nil)

            })
            .disposed(by: rx.disposeBag)
    }
    
    @IBAction func btn(_ sender: Any) {
        print(currentUser.displayName)
    }
    
}

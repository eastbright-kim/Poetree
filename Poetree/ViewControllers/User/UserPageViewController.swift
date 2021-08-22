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
        
//        userRegister.rx.tap
//            .subscribe(onNext:{[unowned self]
//                _ in
//                let viewModel = UserRegisterViewModel()
//                var vc = UserRegisterViewController.instantiate(storyboardID: "UserRelated")
//                vc.bind(viewModel: viewModel)
//                self.present(vc, animated: true, completion: nil)
//
//            })
//            .disposed(by: rx.disposeBag)
        
        navBarBtn.rx.tap
            .subscribe(onNext:{ [unowned self] _ in
                
                
                let sb = UIStoryboard(name: "UserRelated", bundle: nil)
                let vc = sb.instantiateViewController(identifier: "SecondViewController") as! SecondViewController
                
                
                present(vc, animated: false, completion: nil)
//                let sb = UIStoryboard(name: "UserRelated", bundle: nil)
//
//                guard let vc = sb.instantiateViewController(identifier: "SideMenuViewController") as? SideMenuViewController else {return}
//
//                let nav = SideMenuNavigation(rootViewController: vc)
//
//                present(nav, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    
    @IBAction func btn(_ sender: Any) {
        print(currentUser.displayName)
    }
    
}

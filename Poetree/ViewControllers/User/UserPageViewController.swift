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
    @IBOutlet weak var pennameLabel: UILabel!
    @IBOutlet weak var userWritingLabel: UILabel!
    @IBOutlet weak var myWritingTableView: UITableView!
    @IBOutlet weak var userLikedLabel: UILabel!
    @IBOutlet weak var likedWrtingsTableView: UITableView!
    @IBOutlet weak var logout: UIButton!
    
    
    var viewModel: MyPoemViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pennameLabel.alpha = 0
        greetingAni()
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
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }
    
    func bindViewModel() {
        
        self.viewModel.output.loginUser
            .drive(onNext:{ [unowned self] loginUser in
                
                if loginUser.userEmail == "unknowned" {
                    self.userWritingLabel.text = "비회원"
                    self.userLikedLabel.text = "비회원"
                }else {
                    self.userWritingLabel.rx.text.onNext("\(loginUser.userPenname)님의 글")
                    self.userLikedLabel.rx.text.onNext("\(loginUser.userPenname)님의 글")
                }
            })
            .disposed(by: rx.disposeBag)
        
        self.navBarBtn.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                
                let currentUser = Auth.auth().currentUser
                
                guard currentUser == nil else {return}
                
                let vm = UserRegisterViewModel(userService: self.viewModel.userService)
                var vc = UserRegisterViewController.instantiate(storyboardID: "UserRelated")
                vc.bind(viewModel: vm)
                self.present(vc, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
        self.viewModel.output.userWritings
            .bind(to: myWritingTableView.rx.items(cellIdentifier: "UserWritingTableViewCell", cellType: UserWritingTableViewCell.self)){ indexPath, poem, cell in
                
                cell.titleLabel.text = poem.title
                cell.likesCountLabel.text = "\(poem.likers.count)"
            }
            .disposed(by: rx.disposeBag)
        
        self.viewModel.output.userLikedWritings
            .bind(to: likedWrtingsTableView.rx.items(cellIdentifier: "UserLikedWritingTableViewCell", cellType: UserLikedWritingTableViewCell.self)){ indexPath, poem, cell in
                
                cell.titleLabel.text = poem.title
                cell.authorLabel.text = poem.userPenname
                cell.likesCountLabel.text = "\(poem.likers.count)"
            }
            .disposed(by: rx.disposeBag)
        
        self.logout.rx.tap
            .subscribe(onNext:{_ in
                print("log out")
                self.viewModel.userService.logout()
            })
            .disposed(by: rx.disposeBag)
    }
    
    func greetingAni(){
        
        if let _ = Auth.auth().currentUser {
            
            self.viewModel.output.loginUser
                .drive(onNext:{ user in
                    
                    if user.userPenname == "비회원" {
                        self.pennameLabel.text = "좋은 아침 입니다."
                    }
                    
                    self.pennameLabel.rx.text.onNext("\(user.userPenname)님")
                    
                })
                .disposed(by: rx.disposeBag)
            
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
                self.pennameLabel.alpha = 1
            } completion: { firstGreetingFadeIn in
                print(firstGreetingFadeIn)
            }
        } else {
            self.pennameLabel.alpha = 1
        }
    }
}

extension UserPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.height) / 5
    }
    
}

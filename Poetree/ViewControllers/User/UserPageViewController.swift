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
    @IBOutlet weak var greetingLabel: UIView!
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
    }
    
    
    @IBAction func logout(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}

extension UserPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.height) / 5
    }
    
}

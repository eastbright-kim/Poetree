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
    @IBOutlet weak var userLikedLabel: UILabel!
    @IBOutlet weak var likedWrtingsTableView: UITableView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet weak var userWritingCollectionView: UICollectionView!
    @IBOutlet weak var userWritingMoreBtn: UIButton!
    @IBOutlet weak var userWritingMoreBtn2: UIButton!
    @IBOutlet weak var likeWritingMoreBtn: UIButton!
    @IBOutlet weak var likeWritingMoreBtn2: UIButton!
    
    
    var viewModel: MyPoemViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        collectionViewDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pennameLabel.alpha = 0
        self.greetingLabel.alpha = 0
        greetingAni()
        naviBarConfig()
    }
    
    func naviBarConfig(){
        self.navigationController?.navigationBar.tintColor = UIColor.label
        self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func configureUI() {
        configureNavTab()
        makeShadow()
        likedWrtingsTableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    func setGreetingView(){
        greetingView.layer.cornerRadius = 8
        greetingView.layer.borderColor = UIColor.systemGray5.cgColor
        greetingView.layer.borderWidth = 1
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
    
    func collectionViewDelegate(){
        userWritingCollectionView.decelerationRate = .fast
        userWritingCollectionView.isPagingEnabled = false
        userWritingCollectionView.delegate = self
        
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: 150, height: self.userWritingCollectionView.frame.height)
        flowlayout.minimumInteritemSpacing = 10
        flowlayout.scrollDirection = .horizontal
        
        userWritingCollectionView.collectionViewLayout = flowlayout
    }
    
    func bindViewModel() {
        
        self.viewModel.output.loginUser
            .drive(onNext:{ [unowned self] loginUser in
                
                if loginUser.userEmail == "unknowned" {
                    self.userWritingLabel.text = "내가 쓴 글"
                    self.userLikedLabel.text = "내가 좋아한 글"
                }else {
                    self.userWritingLabel.rx.text.onNext("\(loginUser.userPenname)님의 글")
                    self.userLikedLabel.rx.text.onNext("\(loginUser.userPenname)님이 좋아한 글")
                }
            })
            .disposed(by: rx.disposeBag)
        
        self.navBarBtn.rx.tap
            .subscribe(onNext:{
                
                guard let menuVC = UIStoryboard(name: "UserRelated", bundle: nil).instantiateViewController(identifier: "SideMenuViewController") as? SideMenuViewController else {return}
                
                let viewModel = SideMenuViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                menuVC.viewModel = viewModel
                let menu = SideMenuNavigationController(rootViewController: menuVC)
                menu.presentationStyle = .menuSlideIn
                menu.presentationStyle.backgroundColor = .white
                menu.presentationStyle.presentingEndAlpha = 0.5
                self.present(menu, animated: true, completion: nil)
                
            })
            .disposed(by: rx.disposeBag)
        
        self.viewModel.output.userWritings
            .bind(to: self.userWritingCollectionView.rx.items(cellIdentifier: "UserWritingCollectionViewCell", cellType: UserWritingCollectionViewCell.self)){
                indexPath, poem, cell in
                
                cell.imageView.kf.setImage(with: poem.photoURL)
                cell.titleLabel.text = poem.title
                cell.dateLabel.text = convertDateToString(format: "yyyy MMM d", date: poem.uploadAt)
                cell.likeStatusBtn.isHidden = (indexPath != 0)
                cell.likeStackView.isHidden = (indexPath != 1 && indexPath != 2)
                
                cell.isUserInteractionEnabled = !((indexPath == 0) && (poem.id == "no writings yet"))
                
                switch indexPath {
                case 0:
                    cell.likeStatusBtn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
                    cell.likeStatusBtn.setTitle("Most favorite", for: .normal)
                    cell.likeStatusBtn.layer.cornerRadius = 8
                case 1:
                    cell.likesCountLabel.text = "\(poem.likers.count)"
                case 2:
                    cell.likesCountLabel.text = "\(poem.likers.count)"
                default:
                    break
                }
            }
            .disposed(by: rx.disposeBag)
        
        
        
        self.viewModel.output.userLikedWritings
            .bind(to: likedWrtingsTableView.rx.items(cellIdentifier: "UserLikedWritingTableViewCell", cellType: UserLikedWritingTableViewCell.self)){ indexPath, poem, cell in
                
                cell.titleLabel.text = poem.title
                cell.authorLabel.text =  "by. \(poem.userPenname)"
                cell.likesCountLabel.text = "\(poem.likers.count)"
                cell.selectionStyle = .none
            }
            .disposed(by: rx.disposeBag)
        
        
        self.userWritingCollectionView.rx.modelSelected(Poem.self)
            .subscribe(onNext:{ poem in
                
                let viewModel = SemiDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                
                var semiDetailVC = SemiDetailViewController.instantiate(storyboardID: "WritingRelated")
                semiDetailVC.bind(viewModel: viewModel)
                semiDetailVC.modalPresentationStyle = .custom
                semiDetailVC.modalTransitionStyle = .crossDissolve
                self.present(semiDetailVC, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        self.userWritingMoreBtn.rx.tap
            .subscribe(onNext:{ _ in
                
                guard let currentUser = Auth.auth().currentUser else { self.view.makeToast("로그인 이후에 확인하실 수 있습니다", duration: 1.0, position: .center)
                    return}
                
                let currentAuth = CurrentAuth(userEmail: currentUser.email!, userPenname: currentUser.displayName!, userUID: currentUser.uid)
                
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, listType: .userWrote(currentAuth))
                var listVC = PoemListViewController.instantiate(storyboardID: "ListRelated")
                listVC.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(listVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        self.userWritingMoreBtn2.rx.tap
            .subscribe(onNext:{ _ in
                
                guard let currentUser = Auth.auth().currentUser else { self.view.makeToast("로그인 이후에 확인하실 수 있습니다", duration: 1.0, position: .center)
                    return}
                
                let currentAuth = CurrentAuth(userEmail: currentUser.email!, userPenname: currentUser.displayName!, userUID: currentUser.uid)
                
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, listType: .userWrote(currentAuth))
                var listVC = PoemListViewController.instantiate(storyboardID: "ListRelated")
                listVC.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(listVC, animated: true)
                
            })
            .disposed(by: rx.disposeBag)
        
        self.likedWrtingsTableView.rx.modelSelected(Poem.self)
            .subscribe(onNext:{ poem in
               
                let viewModel = SemiDetailViewModel(poem: poem, poemService: self.viewModel.poemService, userService: self.viewModel.userService)
                
                var semiDetailVC = SemiDetailViewController.instantiate(storyboardID: "WritingRelated")
                semiDetailVC.bind(viewModel: viewModel)
                semiDetailVC.modalPresentationStyle = .custom
                semiDetailVC.modalTransitionStyle = .crossDissolve
                self.present(semiDetailVC, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
        self.likeWritingMoreBtn.rx.tap
            .subscribe(onNext:{ _ in
                
                
                guard let currentUser = Auth.auth().currentUser else { self.view.makeToast("로그인 이후에 확인하실 수 있습니다", duration: 1.0, position: .center)
                return}
                
                let currentAuth = CurrentAuth(userEmail: currentUser.email!, userPenname: currentUser.displayName!, userUID: currentUser.uid)
                
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, listType: .userLiked(currentAuth))
                var listVC = PoemListViewController.instantiate(storyboardID: "ListRelated")
                listVC.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(listVC, animated: true)
                
            })
            .disposed(by: rx.disposeBag)
        
        self.likeWritingMoreBtn2.rx.tap
            .subscribe(onNext:{ _ in
                
                guard let currentUser = Auth.auth().currentUser else { self.view.makeToast("로그인 이후에 확인하실 수 있습니다", duration: 1.0, position: .center)
                    return}
                
                let currentAuth = CurrentAuth(userEmail: currentUser.email!, userPenname: currentUser.displayName!, userUID: currentUser.uid)
                
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemService, userService: self.viewModel.userService, listType: .userLiked(currentAuth))
                var listVC = PoemListViewController.instantiate(storyboardID: "ListRelated")
                listVC.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(listVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func greetingAni(){
        
        if let _ = Auth.auth().currentUser {
            
            self.viewModel.output.loginUser
                .drive(onNext:{ user in
                    
                    if user.userPenname == "비회원" {
                        self.pennameLabel.text = self.viewModel.userService.greetingLine(date: Date())
                    }
                    
                    self.pennameLabel.rx.text.onNext("\(user.userPenname)님")
                    self.greetingLabel.text = self.viewModel.userService.greetingLine(date: Date())
                })
                .disposed(by: rx.disposeBag)
            
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
                self.pennameLabel.alpha = 1
            } completion: { pennameFadeInComplete in
                
                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut) {
                    self.pennameLabel.alpha = 0
                    
                } completion: { fadeOutComplete in
                    UIView.animate(withDuration: 1,delay: 0.5) {
                        self.greetingLabel.alpha = 1
                    }
                    
                }
            }
            
        } else {
            self.greetingLabel.text = self.viewModel.userService.greetingLine(date: Date())
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
                self.greetingLabel.alpha = 1
            }
        }
    }
    
    func makeShadow() {
        greetingView.layer.cornerRadius = 8
        greetingView.layer.shadowColor = UIColor.systemGray5.cgColor
        greetingView.layer.shadowRadius = 5
        greetingView.layer.shadowOffset = .zero
        greetingView.layer.shadowOpacity = 0.4
 
    }
    
}

extension UserPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.height) / 5
    }
    
}

extension UserPageViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: self.userWritingCollectionView.frame.height)
    }
}

//
//  SideMenuViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/21.
//

import UIKit
import Firebase
import Toast_Swift

class SideMenuViewController: UIViewController{
    
    
    var viewModel: SideMenuViewModel!
    @IBOutlet weak var menuTableView: UITableView!
    
    
    lazy var register_login = SideMenuCell(title: "회원가입 / 로그인", btnAction: {
        let viewModel = UserRegisterViewModel(userService: self.viewModel.userService)
        
        var registerVC = UserRegisterViewController.instantiate(storyboardID: "UserRelated")
        registerVC.bind(viewModel: viewModel)
        self.navigationController?.pushViewController(registerVC, animated: true)

    })
    
    lazy var logout = SideMenuCell(title: "Log out", btnAction: {
        self.viewModel.userService.logout()
        self.dismiss(animated: true, completion: nil)
    })
    lazy var aboutPoetree = SideMenuCell(title: "About Poetree", btnAction: {
                    
        let aboutPoetreeVC = AboutPoetreeViewController.instantiate(storyboardID: "SideMenuRelated")
        self.navigationController?.pushViewController(aboutPoetreeVC, animated: true)
        
    })
    lazy var sendPhoto = SideMenuCell(title: "사진 보내기", btnAction: {
        let noticeDetailViewController = NoticeDetailViewController.instantiate(storyboardID: "SideMenuRelated")
        self.navigationController?.pushViewController(noticeDetailViewController, animated: true)
    })
    
    lazy var notice = SideMenuCell(title: "공지사항", btnAction: {
        let noticeVC = NoticeViewController.instantiate(storyboardID: "SideMenuRelated")
        let noticeViewModel = NoticeViewModel(notices: self.viewModel.userService.notices)
        noticeVC.noticeViewModel = noticeViewModel
        self.navigationController?.pushViewController(noticeVC, animated: true)
    })
    
    lazy var savedWritings = SideMenuCell(title: "임시 저장한 글", btnAction: {
        
        if let currentUser = Auth.auth().currentUser {
            let viewModel = PoemListViewModel(poemService: self.viewModel.poemServcie, userService: self.viewModel.userService, listType: .tempSaved(currentUser))
            var listVC = PoemListViewController.instantiate(storyboardID: "ListRelated")
            listVC.bind(viewModel: viewModel)
            self.navigationController?.pushViewController(listVC, animated: true)
        }
    })
    
    
    lazy var loginUser = [savedWritings, sendPhoto, notice, aboutPoetree, logout]
    lazy var logoutUser = [register_login, sendPhoto, notice, aboutPoetree]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.tableFooterView = UIView()
        menuTableView.cellLayoutMarginsFollowReadableWidth = false
        menuTableView.separatorInset.left = 20
        menuTableView.separatorInset.right = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
}


extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let _ = Auth.auth().currentUser {
            return self.loginUser.count
        } else {
            return self.logoutUser.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let _ = Auth.auth().currentUser {
            
            let setCell = self.loginUser[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell") as? SideMenuTableViewCell else {return UITableViewCell()}
            
            cell.titleLabel.text = setCell.title
            cell.btnAction = setCell.btnAction
            
            return cell
        } else {
            
            let setCell = self.logoutUser[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell") as? SideMenuTableViewCell else {return UITableViewCell()}
            
            cell.titleLabel.text = setCell.title
            cell.btnAction = setCell.btnAction
            return cell
        }
        
    }
}


struct SideMenuCell {
    let title: String
    let btnAction: (()-> Void)
}

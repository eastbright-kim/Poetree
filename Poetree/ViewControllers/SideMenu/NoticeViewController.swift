//
//  NoticeViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/21.
//

import UIKit
import RxSwift
import RxCocoa

class NoticeViewController: UITableViewController, StoryboardBased {

    @IBOutlet var noticeTableView: UITableView!
    
    var noticeViewModel: NoticeViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        self.title = "공지사항"
    }
    
    func bindViewModel() {
        
        noticeViewModel.noticeObservable
            .bind(to: noticeTableView.rx.items(cellIdentifier: "noticeCell")){ index, notice, cell in
                cell.textLabel?.text = notice.title
            }
            .disposed(by: rx.disposeBag)
        
        
        noticeTableView.rx.modelSelected(Notice.self)
            .subscribe(onNext:{ notice in
                
                
                
            })
            .disposed(by: rx.disposeBag)
    }
}


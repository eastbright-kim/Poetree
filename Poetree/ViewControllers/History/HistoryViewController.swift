//
//  HistoryViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit

class HistoryViewController: UIViewController, ViewModelBindable, StoryboardBased {

    
    @IBOutlet weak var allPoemsBtn: UIButton!
    
    
    var viewModel: HistoryViewModel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    private func configureUI() {
        
        configureNavTab()
        
    }
    
    private func configureNavTab() {
        self.navigationItem.title = "History"
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.tabBarItem.image = UIImage(systemName: "book.fill")
        self.tabBarItem.selectedImage = UIImage(systemName: "book.fill")
        self.tabBarItem.title = "History"
    }
    
    
    func bindViewModel() {
        
        allPoemsBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                
                let viewModel = PoemListViewModel(poemService: self.viewModel.poemSevice)
                var vc = PoemListViewController.instantiate(storyboardID: "ListRelated")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
}

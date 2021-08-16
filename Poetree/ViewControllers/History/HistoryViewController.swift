//
//  HistoryViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit

class HistoryViewController: UIViewController, ViewModelBindable, StoryboardBased {

    
    
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
        
    }
    
    

}

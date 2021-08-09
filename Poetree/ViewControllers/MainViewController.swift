//
//  MainViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/09.
//

import UIKit
import FSPagerView

class MainViewController: UIViewController {
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var pageView: FSPagerView!{
        didSet{
            self.pageView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            
            self.pageView.itemSize = FSPagerView.automaticSize
            
            self.pageView.isInfinite = true
            
            self.pageView.transformer = FSPagerViewTransformer(type: .linear)
        }
    }
    @IBOutlet weak var thisWeekBtn1: UIButton!
    
    @IBOutlet weak var writeBtn: UIButton!
    @IBOutlet weak var writeChev: UIButton!
    
    
    @IBOutlet weak var poemTableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}

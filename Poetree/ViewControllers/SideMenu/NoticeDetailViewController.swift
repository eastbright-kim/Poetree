//
//  NoticeDetailViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/21.
//

import UIKit

class NoticeDetailViewController: UIViewController, StoryboardBased {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var notice: Notice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNotice()
        
    }
    
    func setUpNotice() {
        
        if let notice = self.notice {
            titleLabel.text = notice.title
            contentLabel.text = notice.content
        }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        self.contentLabel.attributedText = NSAttributedString(string: self.contentLabel.text!, attributes: attributes)
        self.contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
    }
}

//
//  AboutPoetreeViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/21.
//

import UIKit

class AboutPoetreeViewController: UIViewController, StoryboardBased {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var infoTextField: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoImage.layer.cornerRadius = 8
        
        configureUI()
        
    }

    func configureUI(){
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        self.infoTextField.attributedText = NSAttributedString(string: self.infoTextField.text!, attributes: attributes)
        self.infoTextField.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
    }
    
}

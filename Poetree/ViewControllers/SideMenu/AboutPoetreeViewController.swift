//
//  AboutPoetreeViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/21.
//

import UIKit

class AboutPoetreeViewController: UIViewController, StoryboardBased {

    @IBOutlet weak var photoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoImage.layer.cornerRadius = 8
    }

}

//
//  SideMenuNavigationController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/21.
//

import UIKit
import SideMenu

class SideMenuNavigation: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationStyle = .menuSlideIn
//        self.presentationStyle.backgroundColor = .black
//        self.presentationStyle.presentingEndAlpha = 0.7
        self.presentDuration = 0.5
        self.dismissDuration = 0.5
        
    }
    


}

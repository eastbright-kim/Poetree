//
//  SideMenuTableViewCell.swift
//  Poetree
//
//  Created by κΉλν on 2021/09/12.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var btnAction:(()->Void)!

    @IBAction func segueBtnTapped(_ sender: UIButton) {
        btnAction()
    }
    
}

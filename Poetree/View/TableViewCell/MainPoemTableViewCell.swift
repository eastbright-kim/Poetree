//
//  MainPoemTableViewCell.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit

class MainPoemTableViewCell: UITableViewCell {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeCountStackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}

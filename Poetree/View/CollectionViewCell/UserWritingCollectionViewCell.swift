//
//  UserWritingCollectionViewCell.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/12.
//

import UIKit

class UserWritingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeStatusBtn: UIButton!
    @IBOutlet weak var likeStackView: UIStackView!
    @IBOutlet weak var likesCountLabel: UILabel!
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.masksToBounds = true
    }
    
}

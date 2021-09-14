//
//  MainPhotoCollectionViewCell.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/12.
//

import UIKit

class MainPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var todayImage: UIImageView!
    
    override func awakeFromNib() {
        self.todayImage.layer.cornerRadius = 8
        
    }
}

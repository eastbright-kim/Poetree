//
//  MainPhotoCollectionViewCell.swift
//  Poetree
//
//  Created by κΉλν on 2021/08/12.
//

import UIKit

class MainPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var todayImage: UIImageView!
    
    override func awakeFromNib() {
        self.todayImage.layer.cornerRadius = 8
        
    }
}

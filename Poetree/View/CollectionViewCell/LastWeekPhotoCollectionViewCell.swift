//
//  LastWeekPhotoCollectionViewCell.swift
//  Poetree
//
//  Created by κΉλν on 2021/08/31.
//

import UIKit

class LastWeekPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lastWeekPhotoImageView: UIImageView!
    
    override func awakeFromNib() {
        lastWeekPhotoImageView.layer.cornerRadius = 8
    }
    
}

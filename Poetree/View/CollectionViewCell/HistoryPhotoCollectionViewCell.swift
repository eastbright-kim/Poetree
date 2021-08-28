//
//  HistoryPhotoCollectionViewCell.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/28.
//

import UIKit

class HistoryPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        
        photoImageView.layer.cornerRadius = 8
        
    }
    
}

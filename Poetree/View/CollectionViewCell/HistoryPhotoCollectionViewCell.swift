//
//  HistoryPhotoCollectionViewCell.swift
//  Poetree
//
//  Created by κΉλν on 2021/08/28.
//

import UIKit

class HistoryPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        
        photoImageView.layer.cornerRadius = 8
        
    }
    
}

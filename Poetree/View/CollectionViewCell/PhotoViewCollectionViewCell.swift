//
//  PhotoViewCollectionViewCell.swift
//  Poetree
//
//  Created by κΉλν on 2021/08/26.
//

import UIKit

class PhotoViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        self.imageView.layer.cornerRadius = 8
    }
}

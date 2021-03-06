//
//  PoemListTableViewCell.swift
//  Poetree
//
//  Created by κΉλν on 2021/08/17.
//

import UIKit

class PoemListTableViewCell: UITableViewCell {

    @IBOutlet weak var poemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesStackView: UIStackView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        poemImageView.layer.cornerRadius = 8
    }

}

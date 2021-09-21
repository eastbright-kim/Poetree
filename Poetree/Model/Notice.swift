//
//  Notice.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/21.
//

import Foundation

class Notice {
    
    let title: String
    let content: String
    let uploadDate: Date
    init(title: String, content: String, uploadDate: Date) {
        self.title = title
        self.content = content
        self.uploadDate = uploadDate
    }
    
}

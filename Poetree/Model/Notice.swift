//
//  Notice.swift
//  Poetree
//
//  Created by κΉλν on 2021/09/21.
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

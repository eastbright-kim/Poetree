//
//  Notice.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/21.
//

import Foundation

struct NoticeEntity {
    
    let title: String
    let content: String
    let uploadDate: String
    init(noticeDic: [String:String]){
        self.title = noticeDic["title"] ?? ""
        self.content = noticeDic["content"] ?? ""
        self.uploadDate = noticeDic["uploadDate"] ?? ""
    }
    
}

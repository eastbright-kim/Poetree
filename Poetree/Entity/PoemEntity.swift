//
//  Poem.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/12.
//

import Foundation

struct PoemEntity: Codable {
    
    var title: String
    var content: String
    let id: Int
    let photoId: Int
    let uploadAt: String
    var isPublic: String
    var likers: [String]
    var userEmail: String
    var penName: String
    
    init(poemDic: [String:Any]) {
        self.title = poemDic["title"] as? String ?? ""
        self.content = poemDic["content"] as? String ?? ""
        self.userEmail = poemDic["userEmail"] as? String ?? ""
        self.penName = poemDic["penName"] as? String ?? ""
        self.penName = poemDic["penName"] as? String ?? ""
        self.uploadAt = poemDic["uploadAt"] as? String ?? ""
        self.id = poemDic["id"] as? Int ?? 0
        self.photoId = poemDic["photoId"] as? Int ?? 0
        self.isPublic = poemDic["isPublic"] as? String ?? ""
        self.likers = poemDic["likers"] as? [String] ?? [""]
    }
    
}

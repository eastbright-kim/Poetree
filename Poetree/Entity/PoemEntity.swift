//
//  Poem.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/12.
//

import Foundation

struct PoemEntity: Codable {
    
    let id: String
    let userEmail: String
    let userNickname: String
    var title: String
    var content: String
    let photoId: Int
    let uploadAt: String
    var isPublic: Bool
    var likers: [String:Bool]
    let photoURL: String
  
    init(poemDic: [String:Any]) {
        self.title = poemDic["title"] as? String ?? ""
        self.content = poemDic["content"] as? String ?? ""
        self.userEmail = poemDic["userEmail"] as? String ?? ""
        self.photoURL = poemDic["photoURL"] as? String ?? ""
        self.userNickname = poemDic["userNickname"] as? String ?? ""
        self.uploadAt = poemDic["uploadAt"] as? String ?? ""
        self.id = poemDic["id"] as? String ?? ""
        self.photoId = poemDic["photoId"] as? Int ?? 0
        self.isPublic = poemDic["isPublic"] as? Bool ?? true
        self.likers = poemDic["likers"] as? [String:Bool] ?? [:]
    }
}

struct PhotoEntity: Codable {
    let date: String
    let photoId: Int
    let imageURL: String
    
    init(photoDic: [String: Any]) {
        self.date = photoDic["date"] as? String ?? ""
        self.photoId = photoDic["id"] as? Int ?? 0
        self.imageURL = photoDic["url"] as? String ?? ""
    }
    
}

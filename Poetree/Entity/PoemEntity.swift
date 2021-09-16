//
//  Poem.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/12.
//

import Foundation

struct PoemEntity {
    
    let id: String
    let userEmail: String
    let userNickname: String
    var title: String
    var content: String
    let photoId: Int
    let uploadAt: String
    var isPrivate: Bool
    var likers: [String:Bool]
    let photoURL: String
    let userUID: String
    var isTemp: Bool
  
    init(poemDic: [String:Any]) {
        self.title = poemDic["title"] as? String ?? ""
        self.content = poemDic["content"] as? String ?? ""
        self.userEmail = poemDic["userEmail"] as? String ?? ""
        self.photoURL = poemDic["photoURL"] as? String ?? ""
        self.userNickname = poemDic["userPenname"] as? String ?? ""
        self.uploadAt = poemDic["uploadAt"] as? String ?? ""
        self.id = poemDic["id"] as? String ?? ""
        self.photoId = poemDic["photoId"] as? Int ?? 0
        self.isPrivate = poemDic["isPrivate"] as? Bool ?? false
        self.likers = poemDic["likers"] as? [String:Bool] ?? [:]
        self.userUID = poemDic["userUID"] as? String ?? ""
        self.isTemp = poemDic["isTemp"] as? Bool ?? false
    }
}


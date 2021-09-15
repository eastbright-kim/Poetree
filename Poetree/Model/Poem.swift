//
//  Poem.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit


class Poem: Equatable, Identifiable {
    
    let id: String
    let userEmail: String
    var userPenname: String
    var title: String
    var content: String
    let photoId: Int
    let uploadAt: Date
    var isPrivate: Bool = false
    var likers = [String:Bool]()
    let photoURL: URL
    var isLike: Bool = false
    let userUID: String
    var isTemp: Bool = false
    
    init(id: String, userEmail: String, userNickname: String, title: String, content: String, photoId: Int, uploadAt: Date, isPrivate: Bool, likers: [String:Bool], photoURL: URL, userUID: String, isTemp: Bool) {
        self.id = id
        self.userEmail = userEmail
        self.userPenname = userNickname
        self.title = title
        self.content = content
        self.photoId = photoId
        self.uploadAt = uploadAt
        self.isPrivate = isPrivate
        self.likers = likers
        self.photoURL = photoURL
        self.userUID = userUID
        self.isLike = likers[userUID] ?? false
        self.isTemp = isTemp
    }
    static func == (lhs: Poem, rhs: Poem) -> Bool {
        return lhs.id == rhs.id
    }
}


struct WeekPhoto: Identifiable, Equatable {
    let date: Date
    let id: Int
    let url: URL
}

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
    var userNickname: String
    var title: String
    var content: String
    let photoId: Int
    let uploadAt: Date
    var isPublic: Bool = true
    var likers: [String]
    let photoURL: URL
    
    init(id: String, userEmail: String, userNickname: String, title: String, content: String, photoId: Int, uploadAt: Date, isPublic: Bool, likers: [String], photoURL: URL) {
        self.id = id
        self.userEmail = userEmail
        self.userNickname = userNickname
        self.title = title
        self.content = content
        self.photoId = photoId
        self.uploadAt = uploadAt
        self.isPublic = isPublic
        self.likers = likers
        self.photoURL = photoURL
    }
    
    
    
    static func == (lhs: Poem, rhs: Poem) -> Bool {
        return true
    }
}


struct WeekPhoto: Identifiable {
    let date: Date
    let id: Int
    let url: URL
}

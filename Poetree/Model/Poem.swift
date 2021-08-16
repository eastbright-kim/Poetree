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
    var likers = [String:Bool]()
    let photoURL: URL
    var isLike: Bool = false
    
    init(id: String, userEmail: String, userNickname: String, title: String, content: String, photoId: Int, uploadAt: Date, isPublic: Bool, likers: [String:Bool], photoURL: URL, userUID: String? = nil) {
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
        if let userUID = userUID {
            self.isLike = likers[userUID] ?? false
        }
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
